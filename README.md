# Condo DAO

<div style="text-align:center" align="center">
    <img src="https://raw.githubusercontent.com/condodao/v1-core/master/logo.svg" width="600" alt="Condo DAO logo">
</div>

The `CondoManager` contract is a comprehensive smart contract designed to manage a system of condominiums represented as NFTs (Non-Fungible Tokens). This contract facilitates the creation, sale, and management of apartments within these condominiums, with each condo functioning as a decentralized autonomous organization (DAO).

Here's a detailed breakdown of its functionality:

### Imports and Interfaces

The contract imports several dependencies:

1. **NFT.sol** - Manages the NFT representation of each condominium.
2. **CondoTimelock.sol** - Provides a timelock mechanism for the condominium's DAO.
3. **CondoGovernor.sol** - Handles the governance of the condominium's DAO.
4. **CondoVault.sol** - Manages the vault for accumulating sales from apartments.
5. **CondoEnums.sol** - Defines various statuses for condos.
6. **CondoEvents.sol** - Defines events for tracking state changes.
7. **CondoStructs.sol** - Defines data structures for condos, apartments, users, ratings, shares, and rents.
8. **CondoErrors.sol** - Defines custom error messages for common error scenarios.

### State Variables

- **nextCondoId, nextApartId, nextUserId, nextRatingId, nextShareId, nextRentId**: Counters for assigning unique IDs.
- **condos, aparts, users, ratings, shares, rents**: Mappings to store the details of condos, apartments, users, ratings, shares, and rents.
- **tokenToCondo**: Maps token IDs to condo IDs.
- **addressToId**: Maps user addresses to user IDs.

### Events

The contract defines multiple events to log significant actions:

- `CondoAdded`
- `CondoUpdated`
- `ApartAdded`
- `UserAdded`
- `UserUpdated`
- `RatingAdded`
- `RatingUpdated`
- `ShareAdded`
- `ShareUpdated`
- `RentAdded`
- `RentUpdated`

### Functions

#### Condo Management

1. **addCondo**: Creates a new condominium DAO with the provided name, symbol, and apartment details.
2. **updCondo**: Updates the status of an existing condominium. Only the condo creator can update its status.
3. **getCondo**: Retrieves the details of a condominium by its ID.
4. **getCondoByToken**: Retrieves the details of a condominium by its token ID.

#### Apartment Management

1. **addApart**: Sells an apartment within a condominium. The buyer pays the specified price to the condo's vault, and the apartment NFT is minted to the buyer.
2. **getApart**: Retrieves the details of an apartment by its ID.
3. **getApartmentDetails**: Retrieves the floor and apartment number of an apartment by its token ID.

#### User Management

1. **addUser**: Adds a new user to the system.
2. **updUser**: Updates an existing user's details. Only the user can update their details.
3. **getUser**: Retrieves the details of a user by their ID.
4. **getUserByAddress**: Retrieves the details of a user by their wallet address.

#### Rating Management

1. **addRating**: Adds a new rating for a user.
2. **updRating**: Updates an existing rating. Only the rater can update the rating.
3. **getRating**: Retrieves the details of a rating by its ID.

#### Share Management

1. **addShare**: Creates a share for renting out an apartment.
2. **updShare**: Updates the details of a share. Only the share creator can update it.
3. **getShare**: Retrieves the details of a share by its ID.

#### Rent Management

1. **addRent**: Initiates a rent agreement for a shared apartment.
2. **updRent**: Updates the balance of an existing rent agreement. Only the renter can update it.
3. **getRent**: Retrieves the details of a rent agreement by its ID.

### Internal Functions

1. **condoTimelock**: Creates a new `CondoTimelock` instance with the necessary configurations.
2. **\_ensureUserExists**: Ensures that a user exists in the system. If not, it creates a new user.
3. **\_addUser**: Adds a new user internally and emits a `UserAdded` event.

### Error Handling

The contract uses custom errors defined in `CondoErrors.sol` to handle common error scenarios like unauthorized access, insufficient payment, and non-existent entities (apartments or users).

### Key Points

- **DAO Integration**: Each condominium functions as a DAO, with its own governance and timelock mechanisms.
- **NFT Representation**: Apartments within condos are represented as NFTs, allowing for unique ownership and transferability.
- **User-Rating System**: Users can rate each other, providing a trust mechanism within the platform.
- **Share and Rent Mechanisms**: Users can share apartments for rent, and renters can manage their rent balances.

This contract offers a comprehensive system for managing condominium DAOs, with robust features for handling apartment sales, user interactions, and rental agreements, all while leveraging the benefits of blockchain technology and NFTs.
