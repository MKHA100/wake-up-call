# ADR-0002: Alarm Trigger Model

## Status
Accepted

## Decision
Use notification-based wake flow and app-level challenge completion window.

## Rationale
- iOS does not guarantee direct interception of hardware buttons for snooze detection.
- Notification + in-app challenge is reliable and App Store-safe.
