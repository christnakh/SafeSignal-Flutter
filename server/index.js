const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql");
const cors = require("cors");

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Database connection
const db = mysql.createConnection({
  host: "127.0.0.1",
  user: "root",
  password: "root",
  database: "delivery",
  port: 8889,
});

db.connect((err) => {
  if (err) {
    console.error("Database connection error: ", err);
    return;
  }
  console.log("Connected to database");
});

app.post("/loginadmin", (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).send("Username and password are required");
  }

  db.query(
    "SELECT * FROM admins WHERE username = ? AND password = ?",
    [email, password],
    (err, results) => {
      if (err) {
        return res.status(500).send("Database error");
      }
      if (results.length === 0) {
        return res.status(401).send("Invalid email or password");
      }
      const admin = results[0]; // Get the first admin from the results
      const adminId = admin.admin_id; // Assuming the column name is admin_id

      res.json({ message: "Login successful", userId: adminId });
    }
  );
});

// Login route
app.post("/login", (req, res) => {
  const { email, password } = req.body;
  const SELECT_USER_QUERY = `SELECT * FROM users WHERE email = ? AND password = ?`;
  db.query(SELECT_USER_QUERY, [email, password], (err, result) => {
    if (err) {
      console.error("Error fetching user: ", err);
      return res.status(500).send("Error fetching user");
    }
    if (result.length === 0) {
      return res.status(204).send("User not found");
    }
    const user = result[0];
    res.status(200).json({ message: "Login successful", userId: user.user_id });
  });
});

// Service provider login route
app.post("/provider/login", (req, res) => {
  const { email, password } = req.body;
  const SELECT_PROVIDER_QUERY = `SELECT * FROM service_providers WHERE email = ?`;
  db.query(SELECT_PROVIDER_QUERY, [email], (err, result) => {
    console.log("3", err);
    console.log("3", result);

    if (err) {
      console.error("Error fetching service provider: ", err);
      res.status(500).send("Error fetching service provider");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Service provider not found");
      return;
    }
    const provider = result[0];
    if (password !== provider.password) {
      res.status(401).send("Incorrect password");
      return;
    }
    res.status(200).json({ userId: provider.provider_id });
  });
});

// Create a new user
app.post("/users", (req, res) => {
  const { first_name, last_name, phone, email, password } = req.body;
  const INSERT_USER_QUERY = `INSERT INTO users (first_name, last_name, phone, email, password) VALUES (?, ?, ?, ?, ?)`;
  db.query(INSERT_USER_QUERY, [first_name, last_name, phone, email, password], (err, result) => {
    if (err) {
      console.error("Error creating user: ", err);
      res.status(500).send("Error creating user");
      return;
    }
    console.log("User created successfully");
    res.status(201).send("User created successfully");
  });
});

// Get a user by ID
app.get("/users/:userId", (req, res) => {
  const userId = req.params.userId;
  const SELECT_USER_QUERY = `SELECT * FROM users WHERE user_id = ?`;
  db.query(SELECT_USER_QUERY, [userId], (err, result) => {
    if (err) {
      console.error("Error fetching user: ", err);
      res.status(500).send("Error fetching user");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("User not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

// Update a user by ID
app.put("/users/:userId", (req, res) => {
  const userId = req.params.userId;
  const { first_name, last_name, phone, email, password } = req.body;
  const UPDATE_USER_QUERY = `UPDATE users SET first_name = ?, last_name = ?, phone = ?, email = ?, password = ? WHERE user_id = ?`;
  db.query(
    UPDATE_USER_QUERY,
    [first_name, last_name, phone, email, password, userId],
    (err, result) => {
      if (err) {
        console.error("Error updating user: ", err);
        res.status(500).send("Error updating user");
        return;
      }
      console.log("User updated successfully");
      res.status(200).send("User updated successfully");
    }
  );
});

// Delete a user by ID
app.delete("/users/:userId", (req, res) => {
  const userId = req.params.userId;
  const DELETE_USER_QUERY = `DELETE FROM users WHERE user_id = ?`;
  db.query(DELETE_USER_QUERY, [userId], (err, result) => {
    if (err) {
      console.error("Error deleting user: ", err);
      res.status(500).send("Error deleting user");
      return;
    }
    console.log("User deleted successfully");
    res.status(200).send("User deleted successfully");
  });
});

// Get all users
app.get("/users", (req, res) => {
  const SELECT_ALL_USERS_QUERY = `SELECT * FROM users`;
  db.query(SELECT_ALL_USERS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching users: ", err);
      res.status(500).send("Error fetching users");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new service request
app.post("/service_requests", (req, res) => {
  const { user_id, service_type, details, estimated_arrival_time, employee_id } = req.body;
  const INSERT_REQUEST_QUERY = `INSERT INTO service_requests (user_id, service_type, details, estimated_arrival_time, employee_id) VALUES (?, ?, ?, ?, ?)`;
  db.query(
    INSERT_REQUEST_QUERY,
    [user_id, service_type, details, estimated_arrival_time, employee_id],
    (err, result) => {
      if (err) {
        console.error("Error creating service request: ", err);
        res.status(500).send("Error creating service request");
        return;
      }
      console.log("Service request created successfully");
      res.status(201).send("Service request created successfully");
    }
  );
});

// Get a service request by ID
app.get("/service_requests/:requestId", (req, res) => {
  const requestId = req.params.requestId;
  const SELECT_REQUEST_QUERY = `SELECT * FROM service_requests WHERE request_id = ?`;
  db.query(SELECT_REQUEST_QUERY, [requestId], (err, result) => {
    if (err) {
      console.error("Error fetching service request: ", err);
      res.status(500).send("Error fetching service request");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Service request not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

app.get("/service_requests/:employeeId", (req, res) => {
  const userId = req.params.employeeId;
  const SELECT_REQUEST_QUERY = `SELECT * FROM service_requests WHERE request_id = ?`;
  db.query(SELECT_REQUEST_QUERY, [userId], (err, result) => {
    if (err) {
      console.error("Error fetching service request: ", err);
      res.status(500).send("Error fetching service request");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Service request not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

app.get("/employees/:employeeId", (req, res) => {
  const employeeId = req.params.employeeId;
  const SELECT_REQUEST_QUERY = `SELECT * FROM service_requests WHERE employee_id = ?`;
  db.query(SELECT_REQUEST_QUERY, [employeeId], (err, result) => {
    if (err) {
      console.error("Error fetching service requests: ", err);
      res.status(500).send("Error fetching service requests");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("No service requests found for this employee");
      return;
    }
    res.status(200).json(result);
  });
});

// Update a service request by ID
app.put("/service_requests/:requestId", (req, res) => {
  const requestId = req.params.requestId;
  const { user_id, service_type, details, estimated_arrival_time, employee_id } = req.body;
  const UPDATE_REQUEST_QUERY = `UPDATE service_requests SET user_id = ?, service_type = ?, details = ?, estimated_arrival_time = ?, employee_id = ? WHERE request_id = ?`;
  db.query(
    UPDATE_REQUEST_QUERY,
    [user_id, service_type, details, estimated_arrival_time, employee_id, requestId],
    (err, result) => {
      if (err) {
        console.error("Error updating service request: ", err);
        res.status(500).send("Error updating service request");
        return;
      }
      console.log("Service request updated successfully");
      res.status(200).send("Service request updated successfully");
    }
  );
});

app.put("/status/:requestId", (req, res) => {
  const requestId = req.params.requestId;
  const { status } = req.body; // Add status parameter
  const UPDATE_REQUEST_QUERY = `UPDATE service_requests SET status = ? WHERE request_id = ?`;
  db.query(UPDATE_REQUEST_QUERY, [status, requestId], (err, result) => {
    if (err) {
      console.error("Error updating service request: ", err);
      res.status(500).send("Error updating service request");
      return;
    }
    console.log("Service request updated successfully");
    res.status(200).send("Service request updated successfully");
  });
});

// Delete a service request by ID
app.delete("/service_requests/:requestId", (req, res) => {
  const requestId = req.params.requestId;
  const DELETE_REQUEST_QUERY = `DELETE FROM service_requests WHERE request_id = ?`;
  db.query(DELETE_REQUEST_QUERY, [requestId], (err, result) => {
    if (err) {
      console.error("Error deleting service request: ", err);
      res.status(500).send("Error deleting service request");
      return;
    }
    console.log("Service request deleted successfully");
    res.status(200).send("Service request deleted successfully");
  });
});

// Get all service requests
app.get("/service_requests", (req, res) => {
  const SELECT_ALL_REQUESTS_QUERY = `SELECT * FROM service_requests`;
  db.query(SELECT_ALL_REQUESTS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching service requests: ", err);
      res.status(500).send("Error fetching service requests");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new transaction
app.post("/transactions", (req, res) => {
  const { request_id, amount, payment_method } = req.body;
  const INSERT_TRANSACTION_QUERY = `INSERT INTO transactions (request_id, amount, payment_method) VALUES (?, ?, ?)`;
  db.query(INSERT_TRANSACTION_QUERY, [request_id, amount, payment_method], (err, result) => {
    if (err) {
      console.error("Error creating transaction: ", err);
      res.status(500).send("Error creating transaction");
      return;
    }
    console.log("Transaction created successfully");
    res.status(201).send("Transaction created successfully");
  });
});

// Get a transaction by ID
app.get("/transactions/:transactionId", (req, res) => {
  const transactionId = req.params.transactionId;
  const SELECT_TRANSACTION_QUERY = `SELECT * FROM transactions WHERE transaction_id = ?`;
  db.query(SELECT_TRANSACTION_QUERY, [transactionId], (err, result) => {
    if (err) {
      console.error("Error fetching transaction: ", err);
      res.status(500).send("Error fetching transaction");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Transaction not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

// Update a transaction by ID
app.put("/transactions/:transactionId", (req, res) => {
  const transactionId = req.params.transactionId;
  const { request_id, amount, payment_method } = req.body;
  const UPDATE_TRANSACTION_QUERY = `UPDATE transactions SET request_id = ?, amount = ?, payment_method = ? WHERE transaction_id = ?`;
  db.query(
    UPDATE_TRANSACTION_QUERY,
    [request_id, amount, payment_method, transactionId],
    (err, result) => {
      if (err) {
        console.error("Error updating transaction: ", err);
        res.status(500).send("Error updating transaction");
        return;
      }
      console.log("Transaction updated successfully");
      res.status(200).send("Transaction updated successfully");
    }
  );
});

// Delete a transaction by ID
app.delete("/transactions/:transactionId", (req, res) => {
  const transactionId = req.params.transactionId;
  const DELETE_TRANSACTION_QUERY = `DELETE FROM transactions WHERE transaction_id = ?`;
  db.query(DELETE_TRANSACTION_QUERY, [transactionId], (err, result) => {
    if (err) {
      console.error("Error deleting transaction: ", err);
      res.status(500).send("Error deleting transaction");
      return;
    }
    console.log("Transaction deleted successfully");
    res.status(200).send("Transaction deleted successfully");
  });
});

// Get all transactions
app.get("/transactions", (req, res) => {
  const SELECT_ALL_TRANSACTIONS_QUERY = `SELECT * FROM transactions`;
  db.query(SELECT_ALL_TRANSACTIONS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching transactions: ", err);
      res.status(500).send("Error fetching transactions");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new rating and feedback
app.post("/ratings_feedback", (req, res) => {
  const { user_id, request_id, rating, feedback } = req.body;
  const INSERT_RATING_QUERY = `INSERT INTO ratings_feedback (user_id, request_id, rating, feedback) VALUES (?, ?, ?, ?)`;
  db.query(INSERT_RATING_QUERY, [user_id, request_id, rating, feedback], (err, result) => {
    if (err) {
      console.error("Error creating rating and feedback: ", err);
      res.status(500).send("Error creating rating and feedback");
      return;
    }
    console.log("Rating and feedback created successfully");
    res.status(201).send("Rating and feedback created successfully");
  });
});

// Get all ratings and feedback
app.get("/ratings_feedback", (req, res) => {
  const SELECT_ALL_RATINGS_QUERY = `SELECT * FROM ratings_feedback`;
  db.query(SELECT_ALL_RATINGS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching ratings and feedback: ", err);
      res.status(500).send("Error fetching ratings and feedback");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new assistance resource
app.post("/assistance_resources", (req, res) => {
  const { title, content, category } = req.body;
  const INSERT_RESOURCE_QUERY = `INSERT INTO assistance_resources (title, content, category) VALUES (?, ?, ?)`;
  db.query(INSERT_RESOURCE_QUERY, [title, content, category], (err, result) => {
    if (err) {
      console.error("Error creating assistance resource: ", err);
      res.status(500).send("Error creating assistance resource");
      return;
    }
    console.log("Assistance resource created successfully");
    res.status(201).send("Assistance resource created successfully");
  });
});

// Get an assistance resource by ID
app.get("/assistance_resources/:resourceId", (req, res) => {
  const resourceId = req.params.resourceId;
  const SELECT_RESOURCE_QUERY = `SELECT * FROM assistance_resources WHERE resource_id = ?`;
  db.query(SELECT_RESOURCE_QUERY, [resourceId], (err, result) => {
    if (err) {
      console.error("Error fetching assistance resource: ", err);
      res.status(500).send("Error fetching assistance resource");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Assistance resource not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

// Update an assistance resource by ID
app.put("/assistance_resources/:resourceId", (req, res) => {
  const resourceId = req.params.resourceId;
  const { title, content, category } = req.body;
  const UPDATE_RESOURCE_QUERY = `UPDATE assistance_resources SET title = ?, content = ?, category = ? WHERE resource_id = ?`;
  db.query(UPDATE_RESOURCE_QUERY, [title, content, category, resourceId], (err, result) => {
    if (err) {
      console.error("Error updating assistance resource: ", err);
      res.status(500).send("Error updating assistance resource");
      return;
    }
    console.log("Assistance resource updated successfully");
    res.status(200).send("Assistance resource updated successfully");
  });
});

// Delete an assistance resource by ID
app.delete("/assistance_resources/:resourceId", (req, res) => {
  const resourceId = req.params.resourceId;
  const DELETE_RESOURCE_QUERY = `DELETE FROM assistance_resources WHERE resource_id = ?`;
  db.query(DELETE_RESOURCE_QUERY, [resourceId], (err, result) => {
    if (err) {
      console.error("Error deleting assistance resource: ", err);
      res.status(500).send("Error deleting assistance resource");
      return;
    }
    console.log("Assistance resource deleted successfully");
    res.status(200).send("Assistance resource deleted successfully");
  });
});

// Get all assistance resources
app.get("/assistance_resources", (req, res) => {
  const SELECT_ALL_RESOURCES_QUERY = `SELECT * FROM assistance_resources`;
  db.query(SELECT_ALL_RESOURCES_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching assistance resources: ", err);
      res.status(500).send("Error fetching assistance resources");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new service provider
app.post("/service_providers", (req, res) => {
  const { provider_name, email, password, role } = req.body;
  const INSERT_PROVIDER_QUERY = `INSERT INTO service_providers (provider_name, email, password, role) VALUES (?, ?, ?, ?)`;
  db.query(INSERT_PROVIDER_QUERY, [provider_name, email, password, role], (err, result) => {
    if (err) {
      console.error("Error creating service provider: ", err);
      res.status(500).send("Error creating service provider");
      return;
    }
    console.log("Service provider created successfully");
    res.status(201).send("Service provider created successfully");
  });
});

// Get a service provider by ID
app.get("/service_providers/:providerId", (req, res) => {
  const providerId = req.params.providerId;
  const SELECT_PROVIDER_QUERY = `SELECT * FROM service_providers WHERE provider_id = ?`;
  db.query(SELECT_PROVIDER_QUERY, [providerId], (err, result) => {
    if (err) {
      console.error("Error fetching service provider: ", err);
      res.status(500).send("Error fetching service provider");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Service provider not found");
      return;
    }

    console.log(result[0]);
    res.status(200).json(result[0]);
  });
});

// Update a service provider by ID
app.put("/service_providers/:providerId", (req, res) => {
  const providerId = req.params.providerId;
  const { provider_name, email, password, role } = req.body;
  const UPDATE_PROVIDER_QUERY = `UPDATE service_providers SET provider_name = ?, email = ?, password = ?, role = ? WHERE provider_id = ?`;
  db.query(
    UPDATE_PROVIDER_QUERY,
    [provider_name, email, password, role, providerId],
    (err, result) => {
      if (err) {
        console.error("Error updating service provider: ", err);
        res.status(500).send("Error updating service provider");
        return;
      }
      console.log("Service provider updated successfully");
      res.status(200).send("Service provider updated successfully");
    }
  );
});

// Delete a service provider by ID
app.delete("/service_providers/:providerId", (req, res) => {
  const providerId = req.params.providerId;
  const DELETE_PROVIDER_QUERY = `DELETE FROM service_providers WHERE provider_id = ?`;
  db.query(DELETE_PROVIDER_QUERY, [providerId], (err, result) => {
    if (err) {
      console.error("Error deleting service provider: ", err);
      res.status(500).send("Error deleting service provider");
      return;
    }
    console.log("Service provider deleted successfully");
    res.status(200).send("Service provider deleted successfully");
  });
});

// Get all service providers
app.get("/service_providers", (req, res) => {
  const SELECT_ALL_PROVIDERS_QUERY = `SELECT * FROM service_providers`;
  db.query(SELECT_ALL_PROVIDERS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching service providers: ", err);
      res.status(500).send("Error fetching service providers");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new admin
app.post("/admins", (req, res) => {
  const { username, password } = req.body;
  const INSERT_ADMIN_QUERY = `INSERT INTO admins (username, password) VALUES (?, ?)`;
  db.query(INSERT_ADMIN_QUERY, [username, password], (err, result) => {
    if (err) {
      console.error("Error creating admin: ", err);
      res.status(500).send("Error creating admin");
      return;
    }
    console.log("Admin created successfully");
    res.status(201).send("Admin created successfully");
  });
});

// Get an admin by ID
app.get("/admins/:adminId", (req, res) => {
  const adminId = req.params.adminId;
  const SELECT_ADMIN_QUERY = `SELECT * FROM admins WHERE admin_id = ?`;
  db.query(SELECT_ADMIN_QUERY, [adminId], (err, result) => {
    if (err) {
      console.error("Error fetching admin: ", err);
      res.status(500).send("Error fetching admin");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Admin not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

// Update an admin by ID
app.put("/admins/:adminId", (req, res) => {
  const adminId = req.params.adminId;
  const { username, password } = req.body;
  const UPDATE_ADMIN_QUERY = `UPDATE admins SET username = ?, password = ? WHERE admin_id = ?`;
  db.query(UPDATE_ADMIN_QUERY, [username, password, adminId], (err, result) => {
    if (err) {
      console.error("Error updating admin: ", err);
      res.status(500).send("Error updating admin");
      return;
    }
    console.log("Admin updated successfully");
    res.status(200).send("Admin updated successfully");
  });
});

// Delete an admin by ID
app.delete("/admins/:adminId", (req, res) => {
  const adminId = req.params.adminId;
  const DELETE_ADMIN_QUERY = `DELETE FROM admins WHERE admin_id = ?`;
  db.query(DELETE_ADMIN_QUERY, [adminId], (err, result) => {
    if (err) {
      console.error("Error deleting admin: ", err);
      res.status(500).send("Error deleting admin");
      return;
    }
    console.log("Admin deleted successfully");
    res.status(200).send("Admin deleted successfully");
  });
});

// Get all admins
app.get("/admins", (req, res) => {
  const SELECT_ALL_ADMINS_QUERY = `SELECT * FROM admins`;
  db.query(SELECT_ALL_ADMINS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching admins: ", err);
      res.status(500).send("Error fetching admins");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new user location
app.post("/locations_user", (req, res) => {
  const { user_id, longitude, latitude } = req.body;
  const INSERT_LOCATION_QUERY = `INSERT INTO locations_user (user_id, longitude, latitude) VALUES (?, ?, ?)`;
  db.query(INSERT_LOCATION_QUERY, [user_id, longitude, latitude], (err, result) => {
    if (err) {
      console.error("Error creating user location: ", err);
      res.status(500).send("Error creating user location");
      return;
    }
    console.log("User location created successfully");
    res.status(201).send("User location created successfully");
  });
});

// Get a user location by ID
app.get("/locations_user/:locationId", (req, res) => {
  const locationId = req.params.locationId;
  const SELECT_LOCATION_QUERY = `SELECT * FROM locations_user WHERE location_id = ?`;
  db.query(SELECT_LOCATION_QUERY, [locationId], (err, result) => {
    if (err) {
      console.error("Error fetching user location: ", err);
      res.status(500).send("Error fetching user location");
      return;
    }
    if (result.length === 0) {
      res.status(304).json({
        location_id: parseInt(locationId),
        user_id: 1,
        longitude: "0",
        latitude: "0",
        last_updated: "2021-10-01 12:00:00",
      });
      // res.status(204).send("User location not found");
      return;
    }

    res.status(200).json(result[0]);
  });
});

// Update a user location by ID
app.put("/locations_user/:locationId", (req, res) => {
  const locationId = req.params.locationId;
  const { user_id, longitude, latitude } = req.body;
  const UPDATE_LOCATION_QUERY = `UPDATE locations_user SET user_id = ?, longitude = ?, latitude = ? WHERE location_id = ?`;
  db.query(UPDATE_LOCATION_QUERY, [user_id, longitude, latitude, locationId], (err, result) => {
    if (err) {
      console.error("Error updating user location: ", err);
      res.status(500).send("Error updating user location");
      return;
    }
    console.log("User location updated successfully");
    res.status(200).send("User location updated successfully");
  });
});

// Delete a user location by ID
app.delete("/locations_user/:locationId", (req, res) => {
  const locationId = req.params.locationId;
  const DELETE_LOCATION_QUERY = `DELETE FROM locations_user WHERE location_id = ?`;
  db.query(DELETE_LOCATION_QUERY, [locationId], (err, result) => {
    if (err) {
      console.error("Error deleting user location: ", err);
      res.status(500).send("Error deleting user location");
      return;
    }
    console.log("User location deleted successfully");
    res.status(200).send("User location deleted successfully");
  });
});

// Get all user locations
app.get("/locations_user", (req, res) => {
  const SELECT_ALL_LOCATIONS_QUERY = `SELECT * FROM locations_user`;
  db.query(SELECT_ALL_LOCATIONS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching user locations: ", err);
      res.status(500).send("Error fetching user locations");
      return;
    }
    res.status(200).json(result);
  });
});

// Create a new employee location
app.post("/locations_employe", (req, res) => {
  const { employee_id, longitude, latitude } = req.body;
  const INSERT_LOCATION_QUERY = `INSERT INTO locations_employe (employee_id, longitude, latitude) VALUES (?, ?, ?)`;
  db.query(INSERT_LOCATION_QUERY, [employee_id, longitude, latitude], (err, result) => {
    if (err) {
      console.error("Error creating employee location: ", err);
      res.status(500).send("Error creating employee location");
      return;
    }
    console.log("Employee location created successfully");
    res.status(201).send("Employee location created successfully");
  });
});

// Get an employee location by ID
app.get("/locations_employe/:locationId", (req, res) => {
  const locationId = req.params.locationId;
  const SELECT_LOCATION_QUERY = `SELECT * FROM locations_employe WHERE location_id = ?`;
  db.query(SELECT_LOCATION_QUERY, [locationId], (err, result) => {
    if (err) {
      console.error("Error fetching employee location: ", err);
      res.status(500).send("Error fetching employee location");
      return;
    }
    if (result.length === 0) {
      res.status(204).send("Employee location not found");
      return;
    }
    res.status(200).json(result[0]);
  });
});

// Update an employee location by ID
app.put("/locations_employe/:locationId", (req, res) => {
  const locationId = req.params.locationId;
  const { employee_id, longitude, latitude } = req.body;
  const UPDATE_LOCATION_QUERY = `UPDATE locations_employe SET employee_id = ?, longitude = ?, latitude = ? WHERE location_id = ?`;
  db.query(UPDATE_LOCATION_QUERY, [employee_id, longitude, latitude, locationId], (err, result) => {
    if (err) {
      console.error("Error updating employee location: ", err);
      res.status(500).send("Error updating employee location");
      return;
    }
    console.log("Employee location updated successfully");
    res.status(200).send("Employee location updated successfully");
  });
});

// Delete an employee location by ID
app.delete("/locations_employe/:locationId", (req, res) => {
  const locationId = req.params.locationId;
  const DELETE_LOCATION_QUERY = `DELETE FROM locations_employe WHERE location_id = ?`;
  db.query(DELETE_LOCATION_QUERY, [locationId], (err, result) => {
    if (err) {
      console.error("Error deleting employee location: ", err);
      res.status(500).send("Error deleting employee location");
      return;
    }
    console.log("Employee location deleted successfully");
    res.status(200).send("Employee location deleted successfully");
  });
});

// Get all employee locations
app.get("/locations_employe", (req, res) => {
  const SELECT_ALL_LOCATIONS_QUERY = `SELECT * FROM locations_employe`;
  db.query(SELECT_ALL_LOCATIONS_QUERY, (err, result) => {
    if (err) {
      console.error("Error fetching employee locations: ", err);
      res.status(500).send("Error fetching employee locations");
      return;
    }
    res.status(200).json(result);
  });
});

// API endpoint to find the nearest employee with the specified role and create a service request
app.post("/find_nearest_employee", (req, res) => {
  const { user_id, latitude, longitude, role, service_type } = req.body;

  // Query to fetch all employee locations with the specified role
  const SELECT_EMPLOYEE_LOCATIONS_QUERY = `SELECT * FROM locations_employe WHERE employee_id IN (SELECT provider_id FROM service_providers WHERE role = ?)`;
  db.query(SELECT_EMPLOYEE_LOCATIONS_QUERY, [role], (err, results) => {
    if (err) {
      console.log("Error fetching employee locations: ", err);
      return res.status(500).send("Error fetching employee locations");
    }

    if (results.length === 0) {
      console.log("No employees found with the specified role");
      return res.status(204).send("No employees found with the specified role");
    }

    let minDistance = Number.MAX_VALUE;
    let nearestEmployee = null;

    // Calculate the distance between the user's location and each employee's location
    results.forEach((employee) => {
      const employeeLatitude = employee.latitude;
      const employeeLongitude = employee.longitude;
      const distance = calculateDistance(latitude, longitude, employeeLatitude, employeeLongitude);

      // Update the nearest employee if the calculated distance is less than the current minimum distance
      if (distance < minDistance) {
        minDistance = distance;
        nearestEmployee = employee;
      }
    });

    // Insert service request into the service_requests table with default values
    const INSERT_REQUEST_QUERY = `INSERT INTO service_requests (user_id, service_type, details, estimated_arrival_time, employee_id) VALUES (?, ?, "DEFAULT", '15 minutes', ?)`;
    if (nearestEmployee && nearestEmployee["employee_id"]) {
      db.query(
        INSERT_REQUEST_QUERY,
        [user_id, service_type, nearestEmployee["employee_id"]],
        (err, result) => {
          console.log("2", err);
          console.log("2", result);
          if (err) {
            console.error("Error creating service request: ", err);
            return res.status(500).send("Error creating service request");
          }
          console.log("Service request created successfully");
          // Return the request_id of the newly inserted row
          const requestId = result.insertId;
          console.log(requestId);
          res.status(201).json({ request_id: requestId });
        }
      );
    } else {
      console.error("No nearest employee found");
      return res.status(204).send("No nearest employee found");
    }
  });
});

function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c; // Distance in km
  return distance;
}

// Function to convert degrees to radians
function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
