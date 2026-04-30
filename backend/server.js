const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;
const DB_FILE = path.join(__dirname, 'data', 'db.json');

app.use(cors());
app.use(express.json()); // Built-in parsing for JSON body
app.use(express.urlencoded({ extended: true })); // Form body parsing for admin form

// Ensure the DB file exists before any read/write operation
function ensureDbFile() {
    if (!fs.existsSync(DB_FILE)) {
        writeDB({ vehicles: [], timelineEvents: [], distanceLogs: [], maintenance: [] });
    }
}

// Helper function to read from JSON file
function readDB() {
    ensureDbFile();
    try {
        const rawData = fs.readFileSync(DB_FILE, 'utf-8');
        return JSON.parse(rawData);
    } catch (e) {
        console.error("Error reading DB file:", e);
        return { vehicles: [], timelineEvents: [], distanceLogs: [], maintenance: [] };
    }
}

// Helper function to write to JSON file
function writeDB(data) {
    ensureDbFile();
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
}

function escapeHtml(text) {
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function generateId(prefix) {
    return `${prefix}${Date.now()}${Math.floor(Math.random() * 1000)}`;
}

function renderAdminPage(db, flash = {}) {
    const vehicleOptions = db.vehicles.map(v => `        <option value="${escapeHtml(v.id)}">${escapeHtml(v.name)} (${escapeHtml(v.plateNumber)})</option>`).join('\n');
    const vehicleRows = db.vehicles.map(v => `        <tr><td>${escapeHtml(v.id)}</td><td>${escapeHtml(v.name)}</td><td>${escapeHtml(v.plateNumber)}</td><td>${escapeHtml(v.location)}</td><td>${escapeHtml(v.battery)}</td></tr>`).join('\n');
    const timelineRows = db.timelineEvents.map(e => `        <tr><td>${escapeHtml(e.id)}</td><td>${escapeHtml(e.vehicleId)}</td><td>${escapeHtml(e.title)}</td><td>${escapeHtml(e.type)}</td><td>${escapeHtml(String(e.mileage))}</td><td>${escapeHtml(e.date)}</td><td>${escapeHtml(String(e.progress))}</td></tr>`).join('\n');
    const distanceRows = db.distanceLogs.map(d => `        <tr><td>${escapeHtml(d.id)}</td><td>${escapeHtml(d.vehicleId)}</td><td>${escapeHtml(d.date)}</td><td>${escapeHtml(String(d.distance))}</td></tr>`).join('\n');
    const maintenanceRows = db.maintenance.map(m => `        <tr><td>${escapeHtml(m.id)}</td><td>${escapeHtml(m.vehicleId)}</td><td>${escapeHtml(m.title)}</td><td>${escapeHtml(m.status)}</td><td>${escapeHtml(m.date)}</td></tr>`).join('\n');

    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>NexVolt Admin</title>
    <style>
        body { font-family: Arial, sans-serif; background: #111; color: #eee; margin: 0; padding: 0; }
        .container { max-width: 1200px; margin: 0 auto; padding: 24px; }
        h1, h2 { color: #00d1b2; }
        .flash { padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; }
        .flash.success { background: rgba(0,209,178,0.12); border: 1px solid #00d1b2; }
        .flash.error { background: rgba(255,80,80,0.12); border: 1px solid #ff5050; }
        .form-card { background: #1a1a1a; border: 1px solid #333; border-radius: 14px; padding: 18px; margin-bottom: 24px; }
        label { display: block; margin-bottom: 6px; color: #bbb; }
        input, select { width: 100%; padding: 10px 12px; border-radius: 10px; border: 1px solid #333; background: #101010; color: #eee; margin-bottom: 14px; }
        button { background: #00d1b2; color: #111; border: none; padding: 12px 20px; border-radius: 10px; cursor: pointer; font-weight: bold; }
        button:hover { opacity: 0.95; }
        table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        th, td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #222; }
        th { color: #fff; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
        .full { grid-column: span 2; }
        @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <div class="container">
        <h1>NexVolt Admin Dashboard</h1>
        <p>Use this admin interface to add new vehicles or data records into the existing JSON database without overwriting any existing records.</p>
        ${flash.message ? `<div class="flash success">${escapeHtml(flash.message)}</div>` : ''}
        ${flash.error ? `<div class="flash error">${escapeHtml(flash.error)}</div>` : ''}

        <div class="form-card">
            <h2>Add Vehicle</h2>
            <form method="POST" action="/admin/vehicles">
                <div class="grid">
                    <div>
                        <label for="name">Vehicle Name</label>
                        <input id="name" name="name" required />
                    </div>
                    <div>
                        <label for="plateNumber">Plate Number</label>
                        <input id="plateNumber" name="plateNumber" required />
                    </div>
                    <div>
                        <label for="battery">Battery (%)</label>
                        <input id="battery" type="number" name="battery" min="0" max="100" step="0.1" value="100" required />
                    </div>
                    <div>
                        <label for="location">Location</label>
                        <input id="location" name="location" required />
                    </div>
                    <div class="full">
                        <label for="imageUrl">Image URL</label>
                        <input id="imageUrl" name="imageUrl" placeholder="https://..." />
                    </div>
                </div>
                <button type="submit">Save Vehicle</button>
            </form>
        </div>

        <div class="form-card">
            <h2>Add Timeline Event</h2>
            <form method="POST" action="/admin/timeline">
                <div class="grid">
                    <div>
                        <label for="timelineVehicleId">Vehicle</label>
                        <select id="timelineVehicleId" name="vehicleId" required>
                            <option value="">Select vehicle</option>
${vehicleOptions}
                        </select>
                    </div>
                    <div>
                        <label for="title">Title</label>
                        <input id="title" name="title" required />
                    </div>
                    <div>
                        <label for="type">Type</label>
                        <select id="type" name="type" required>
                            <option value="maintenance">maintenance</option>
                            <option value="inspection">inspection</option>
                            <option value="charge">charge</option>
                        </select>
                    </div>
                    <div>
                        <label for="mileage">Mileage</label>
                        <input id="mileage" type="number" name="mileage" min="0" step="1" value="0" required />
                    </div>
                    <div>
                        <label for="date">Date</label>
                        <input id="date" type="date" name="date" required />
                    </div>
                    <div>
                        <label for="progress">Progress (0.0-1.0)</label>
                        <input id="progress" type="number" name="progress" min="0" max="1" step="0.01" value="1.0" required />
                    </div>
                </div>
                <button type="submit">Save Timeline Event</button>
            </form>
        </div>

        <div class="form-card">
            <h2>Add Distance Log</h2>
            <form method="POST" action="/admin/distance">
                <div class="grid">
                    <div>
                        <label for="distanceVehicleId">Vehicle</label>
                        <select id="distanceVehicleId" name="vehicleId" required>
                            <option value="">Select vehicle</option>
${vehicleOptions}
                        </select>
                    </div>
                    <div>
                        <label for="distanceDate">Date</label>
                        <input id="distanceDate" type="date" name="date" required />
                    </div>
                    <div>
                        <label for="distance">Distance (km)</label>
                        <input id="distance" type="number" name="distance" min="0" step="0.1" value="0" required />
                    </div>
                </div>
                <button type="submit">Save Distance Log</button>
            </form>
        </div>

        <div class="form-card">
            <h2>Add Maintenance Record</h2>
            <form method="POST" action="/admin/maintenance">
                <div class="grid">
                    <div>
                        <label for="maintenanceVehicleId">Vehicle</label>
                        <select id="maintenanceVehicleId" name="vehicleId" required>
                            <option value="">Select vehicle</option>
${vehicleOptions}
                        </select>
                    </div>
                    <div>
                        <label for="maintenanceTitle">Title</label>
                        <input id="maintenanceTitle" name="title" required />
                    </div>
                    <div>
                        <label for="status">Status</label>
                        <select id="status" name="status" required>
                            <option value="Upcoming">Upcoming</option>
                            <option value="Scheduled">Scheduled</option>
                            <option value="Completed">Completed</option>
                        </select>
                    </div>
                    <div>
                        <label for="maintenanceDate">Date</label>
                        <input id="maintenanceDate" type="date" name="date" required />
                    </div>
                </div>
                <button type="submit">Save Maintenance Record</button>
            </form>
        </div>

        <div class="form-card">
            <h2>Current Data</h2>
            <h3>Vehicles</h3>
            <table>
                <thead><tr><th>ID</th><th>Name</th><th>Plate</th><th>Location</th><th>Battery</th></tr></thead>
                <tbody>
${vehicleRows}
                </tbody>
            </table>
            <h3>Timeline Events</h3>
            <table>
                <thead><tr><th>ID</th><th>Vehicle ID</th><th>Title</th><th>Type</th><th>Mileage</th><th>Date</th><th>Progress</th></tr></thead>
                <tbody>
${timelineRows}
                </tbody>
            </table>
            <h3>Distance Logs</h3>
            <table>
                <thead><tr><th>ID</th><th>Vehicle ID</th><th>Date</th><th>Distance</th></tr></thead>
                <tbody>
${distanceRows}
                </tbody>
            </table>
            <h3>Maintenance Records</h3>
            <table>
                <thead><tr><th>ID</th><th>Vehicle ID</th><th>Title</th><th>Status</th><th>Date</th></tr></thead>
                <tbody>
${maintenanceRows}
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>`;
}

// ------------------------------------------------------------------
// GET ROUTES
// ------------------------------------------------------------------

// Get all vehicles
app.get('/api/vehicles', (req, res) => {
    const db = readDB();
    res.json(db.vehicles || []);
});

// Get specific vehicle by ID
app.get('/api/vehicles/:id', (req, res) => {
    const db = readDB();
    const vehicle = db.vehicles.find(v => v.id === req.params.id);
    if (!vehicle) return res.status(404).json({ error: "Vehicle not found" });
    res.json(vehicle);
});

// Get timeline for vehicle
app.get('/api/vehicles/:id/timeline', (req, res) => {
    const db = readDB();
    const events = db.timelineEvents.filter(e => e.vehicleId === req.params.id);
    res.json(events);
});

// Get distance logs for vehicle
app.get('/api/vehicles/:id/distance', (req, res) => {
    const db = readDB();
    const logs = db.distanceLogs.filter(d => d.vehicleId === req.params.id);
    res.json(logs);
});

// Get maintenance for vehicle
app.get('/api/vehicles/:id/maintenance', (req, res) => {
    const db = readDB();
    const logs = db.maintenance.filter(m => m.vehicleId === req.params.id);
    res.json(logs);
});


// ------------------------------------------------------------------
// POST ROUTES (FORM FILL ENDPOINTS)
// ------------------------------------------------------------------

// Create new vehicle
app.post('/api/vehicles', (req, res) => {
    const db = readDB();
    const newVehicle = {
        id: "v" + Date.now().toString(),
        name: req.body.name || "Unknown Vehicle",
        plateNumber: req.body.plateNumber || "XX 0000",
        battery: req.body.battery || 100,
        imageUrl: req.body.imageUrl || "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        location: req.body.location || "Unknown Location"
    };

    db.vehicles.push(newVehicle);
    writeDB(db);
    res.status(201).json(newVehicle);
});

// Create timeline event
app.post('/api/timeline', (req, res) => {
    const db = readDB();
    const newEvent = {
        id: "t" + Date.now().toString(),
        vehicleId: req.body.vehicleId,
        title: req.body.title || "Note",
        type: req.body.type || "maintenance",
        mileage: req.body.mileage || 0,
        date: req.body.date || new Date().toISOString(),
        progress: req.body.progress || 0.0
    };

    db.timelineEvents.push(newEvent);
    writeDB(db);
    res.status(201).json(newEvent);
});

// Admin interface for manual data entry
app.get('/admin', (req, res) => {
    const db = readDB();
    res.send(renderAdminPage(db));
});

app.post('/admin/vehicles', (req, res) => {
    try {
        const db = readDB();
        const name = String(req.body.name || '').trim();
        const plateNumber = String(req.body.plateNumber || '').trim();
        const battery = Number(req.body.battery);
        const location = String(req.body.location || '').trim();
        const imageUrl = String(req.body.imageUrl || '').trim() || 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';

        if (!name || !plateNumber || Number.isNaN(battery) || battery < 0 || battery > 100 || !location) {
            throw new Error('Please provide valid vehicle name, plate number, battery (0-100), and location.');
        }

        const newVehicle = {
            id: generateId('v'),
            name,
            plateNumber,
            battery,
            imageUrl,
            location,
        };

        db.vehicles.push(newVehicle);
        writeDB(db);
        res.send(renderAdminPage(db, { message: 'Vehicle added successfully.' }));
    } catch (error) {
        const db = readDB();
        res.send(renderAdminPage(db, { error: error.message }));
    }
});

app.post('/admin/timeline', (req, res) => {
    try {
        const db = readDB();
        const vehicleId = String(req.body.vehicleId || '').trim();
        const title = String(req.body.title || '').trim();
        const type = String(req.body.type || 'maintenance').trim();
        const mileage = Number(req.body.mileage);
        const date = String(req.body.date || '').trim();
        const progress = Number(req.body.progress);

        if (!vehicleId || !title || Number.isNaN(mileage) || !date || Number.isNaN(progress) || progress < 0 || progress > 1) {
            throw new Error('Please provide valid timeline event details, including vehicle, title, mileage, date, and progress between 0 and 1.');
        }

        const newEvent = {
            id: generateId('t'),
            vehicleId,
            title,
            type,
            mileage,
            date: new Date(date).toISOString(),
            progress,
        };

        db.timelineEvents.push(newEvent);
        writeDB(db);
        res.send(renderAdminPage(db, { message: 'Timeline event added successfully.' }));
    } catch (error) {
        const db = readDB();
        res.send(renderAdminPage(db, { error: error.message }));
    }
});

app.post('/admin/distance', (req, res) => {
    try {
        const db = readDB();
        const vehicleId = String(req.body.vehicleId || '').trim();
        const date = String(req.body.date || '').trim();
        const distance = Number(req.body.distance);

        if (!vehicleId || !date || Number.isNaN(distance) || distance < 0) {
            throw new Error('Please provide valid distance log details, including vehicle, date, and distance.');
        }

        const newLog = {
            id: generateId('d'),
            vehicleId,
            date: new Date(date).toISOString(),
            distance,
        };

        db.distanceLogs.push(newLog);
        writeDB(db);
        res.send(renderAdminPage(db, { message: 'Distance log added successfully.' }));
    } catch (error) {
        const db = readDB();
        res.send(renderAdminPage(db, { error: error.message }));
    }
});

app.post('/admin/maintenance', (req, res) => {
    try {
        const db = readDB();
        const vehicleId = String(req.body.vehicleId || '').trim();
        const title = String(req.body.title || '').trim();
        const status = String(req.body.status || '').trim();
        const date = String(req.body.date || '').trim();

        if (!vehicleId || !title || !status || !date) {
            throw new Error('Please provide valid maintenance record details, including vehicle, title, status, and date.');
        }

        const newRecord = {
            id: generateId('m'),
            vehicleId,
            title,
            status,
            date: new Date(date).toISOString(),
        };

        db.maintenance.push(newRecord);
        writeDB(db);
        res.send(renderAdminPage(db, { message: 'Maintenance record added successfully.' }));
    } catch (error) {
        const db = readDB();
        res.send(renderAdminPage(db, { error: error.message }));
    }
});

// Start Server
app.listen(PORT, () => {
    console.log(`NexVolt API Server running at http://localhost:${PORT}`);
});
