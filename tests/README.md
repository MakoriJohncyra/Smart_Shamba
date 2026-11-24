# Tests

- `unit/`: isolated tests for utility functions, validators and business logic.
- `integration/`: API/database tests using a dedicated test database.
- `postman/`: importable Postman collections and environment examples.

Backend currently exposes `npm test` using Node's built-in test runner. Add test files named `*.test.js`.
Never point automated tests at production data.
