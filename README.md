# FaaS Contracts
Contracts for FaaS (Fairness as a Service) platform from API3 Latam.

### Contracts
- `core`:
  - `FairHub.sol`: Entry point for all interactions with the platform. Initializes proxies and allow function call forwarding.
  - `Raffle.sol`: Main logic definitions for individual raffles.
  - `storage`:
    - `FairHubStorage.sol`: Storage architecture for FairHub implementation.
  - `base`
    - `AirnodeLogic.sol`: Parent design for airnode implementations. Contains basic utilities and critical outlines for function implementations.
  - `modules`
    - `airnodes`: All the airnode implementations being used across the platform.
      - `WinnerAirnode.sol`: QRNG Airnode implementation for picking a 'winner' out of an array of addresses.
- `interfaces`:
  - `IRaffle.sol`
  - `IFairHub.sol`
  - `IWinnerAirnode.sol`
- `libraries`:
  - `DataTypes.sol`: All the custom data types used across the platform.
  - `Errors.sol`: All the custom errors used across the platform.
  - `Events.sol`: All the custom defined events used across the platform.
- `upgradeability`:
  - `RaffleBeacon.sol`: The beacon for proxy implentation of Raffles.
