# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-24

### 🎉 Initial Release

**Major Features:**
- Complete Traccar API integration with authentication, device management, and reporting
- **Real-time WebSocket support** for live device tracking and event monitoring
- Advanced HTTP client with retry logic, timeout configuration, and comprehensive error handling
- Secure credential storage using Flutter Secure Storage
- Comprehensive error handling with custom exception types
- Full null safety support

**API Coverage:**
- Authentication (login/logout with credential caching)
- Device management (CRUD operations, status monitoring)
- Position tracking and history with real-time updates
- Event management and notifications with live streaming
- Command execution (device control)
- Comprehensive reporting (trips, stops, summary, distance)
- Geofence management
- User and group management
- **WebSocket real-time updates** for devices, positions, and events

**WebSocket Features:**
- Real-time device status updates
- Live position tracking
- Event streaming (geofence violations, alarms, etc.)
- Connection status monitoring
- Automatic reconnection handling
- Configurable connection parameters

**Developer Experience:**
- Extensive documentation and examples
- Type-safe API with comprehensive error handling
- Configurable HTTP client (timeouts, retries, logging)
- Real-time dashboard example app
- Comprehensive test coverage
- WebSocket service with stream-based API

## [0.0.1] - 2024-01-01

### Added
- Initial project setup with Flutter plugin boilerplate
- Basic project structure and dependencies
