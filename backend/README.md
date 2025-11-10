# Portal da Bola - Backend API

Backend API for Portal da Bola, a comprehensive football news platform.

## Features

- News management system
- Multimedia gallery (photos and videos)
- Navigation and search system
- External links integration
- Content recommendation engine

## Technology Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: Microsoft SQL Server
- **Validation**: Zod

## Project Structure

```
src/
├── api/                    # API controllers
│   └── v1/                 # API version 1
│       ├── external/       # Public endpoints
│       └── internal/       # Authenticated endpoints
├── routes/                 # Route definitions
├── middleware/             # Express middleware
├── services/               # Business logic
├── utils/                  # Utility functions
├── constants/              # Application constants
├── instances/              # Service instances
├── config/                 # Configuration
└── server.ts               # Application entry point
```

## Getting Started

### Prerequisites

- Node.js 18+ installed
- SQL Server instance running
- npm or yarn package manager

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment variables:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your database credentials and configuration

4. Run database migrations (when available)

### Development

Start the development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000/api/v1`

### Production Build

Build the project:
```bash
npm run build
```

Start the production server:
```bash
npm start
```

## API Documentation

### Base URL

- Development: `http://localhost:3000/api/v1`
- Production: `https://api.yourdomain.com/api/v1`

### Endpoints

#### Health Check

```
GET /health
```

Returns server health status.

### API Versioning

The API uses URL path versioning:
- Current version: `/api/v1`
- Future versions will be available at `/api/v2`, etc.

## Environment Variables

See `.env.example` for all available configuration options.

## Database

The application uses Microsoft SQL Server with the following schemas:
- `config`: System configuration
- `functional`: Business logic and entities
- `security`: Authentication and authorization
- `subscription`: Account management

## Contributing

Features will be implemented following the project roadmap:
1. News management system
2. Multimedia gallery
3. Navigation and search system

## License

ISC