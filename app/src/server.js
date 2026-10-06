const express = require("express");
const jwt = require("jsonwebtoken");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

const port = process.env.PORT || 8080;
const jwtSecret = process.env.JWT_SECRET || "lab-secret";
const databaseUrl = process.env.DATABASE_URL;

const pool = databaseUrl
  ? new Pool({
      connectionString: databaseUrl,
      ssl: {
        rejectUnauthorized: false
      }
    })
  : null;
// Intentionally vulnerable lab endpoint.
// DO NOT deploy this application to a production environment.
app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "security-agent-demo" });
});

// IDOR-style lab endpoint: authorization is intentionally absent.
app.get("/api/users/:id", async (req, res) => {
  if (!pool) {
    return res.json({
      id: req.params.id,
      email: `user-${req.params.id}@example.local`,
      role: "user"
    });
  }

  try {
    // Intentionally unsafe SQL construction for the security lab.
    const result = await pool.query(
      `SELECT id, email, role FROM users WHERE id = '${req.params.id}'`
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Intentionally weak JWT verification for the lab.
app.get("/api/profile", (req, res) => {
  const token = (req.headers.authorization || "").replace("Bearer ", "");

  try {
    const decoded = jwt.verify(token, jwtSecret);
    res.json({ profile: decoded });
  } catch {
    res.status(401).json({ error: "invalid token" });
  }
});

// Deliberately missing authorization check.
app.get("/api/admin/config", (_req, res) => {
  res.json({
    environment: process.env.NODE_ENV || "lab",
    featureFlags: {
      experimentalSecurityAgentLab: true
    }
  });
});

app.listen(port, () => {
  console.log(`security-agent-demo listening on ${port}`);
});
