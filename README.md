# Sports League Contract & Salary Cap Management System

A comprehensive Clarity smart contract system for managing professional sports league operations, including player contracts, salary cap compliance, transfers, performance bonuses, and injury insurance.

## System Overview

This system consists of five interconnected smart contracts that handle all aspects of sports league management:

### Core Contracts

1. **league-registry.clar** - Central registry managing teams, players, and league settings
2. **player-contracts.clar** - Contract negotiation, terms verification, and lifecycle management
3. **salary-cap.clar** - Salary cap compliance monitoring and enforcement
4. **player-transfers.clar** - Player transfer and trade coordination between teams
5. **performance-bonuses.clar** - Performance bonus calculation, injury insurance, and compensation

## Key Features

### Contract Management
- Multi-year contract creation with guaranteed and incentive-based compensation
- Automatic contract expiration and renewal handling
- Contract modification and amendment capabilities
- Salary escalation and performance clauses

### Salary Cap Compliance
- Real-time salary cap monitoring per team
- Luxury tax calculation for cap violations
- Contract restructuring to maintain compliance
- Historical cap space tracking

### Player Transfers
- Secure player transfer between teams
- Trade approval workflow with league oversight
- Transfer fee calculation and distribution
- Waiver claim processing

### Performance & Insurance
- Automated performance bonus calculations
- Injury insurance claim processing
- Workers compensation management
- Performance milestone tracking

## Data Structures

### Player Profile
- Unique player ID and personal information
- Current team assignment and contract status
- Performance statistics and injury history
- Insurance coverage details

### Team Management
- Team roster with salary allocations
- Current salary cap utilization
- Available cap space calculations
- Trade and transfer history

### Contract Terms
- Base salary and guaranteed money
- Performance incentives and bonuses
- Contract duration and options
- Termination and buyout clauses

## Security Features

- Multi-signature approval for high-value transactions
- Role-based access control (league officials, team management, players)
- Immutable contract history and audit trails
- Automated compliance checks and validations

## Usage Examples

### Creating a Player Contract
```clarity
(contract-call? .player-contracts create-contract 
  u1 ;; player-id
  u2 ;; team-id
  u5000000 ;; base-salary
  u3 ;; contract-years
  (list u100000 u200000 u300000) ;; yearly-bonuses
)
