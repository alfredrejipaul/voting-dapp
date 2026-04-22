# VoteChain — Decentralised Voting DApp

**Module:** CN6035 Decentralised Applications — Task 1
**Author:** Alfred Reji
**Student ID:** 2653857
**Repository:** https://github.com/alfredrejipaul/voting-dapp

---

## Overview

VoteChain is a decentralised voting application built on the Ethereum blockchain. It allows users to vote for candidates through a browser-based frontend, with all voting logic enforced by a Solidity smart contract deployed on the Sepolia testnet. No centralised server is involved.

The project was built by evaluating the open-source repository `maheshmurthy/ethereum_voting_dapp` and identifying its limitations (deprecated testnets, broken dependencies, outdated Truffle toolchain), then rebuilding the concept from scratch using the modern Ethereum development stack.

---

## Technology Stack

- **Solidity 0.8.24** — smart contract language
- **Hardhat** — compilation, deployment, and development environment
- **ethers.js v5** — frontend blockchain interaction
- **MetaMask** — wallet and web3 provider
- **Sepolia Testnet** — Ethereum test network for deployment
- **Solhint** — Solidity static analysis and linting
- **GitHub / Git** — version control

---

## Project Structure

voting-dapp/
├── contracts/
│ └── Voting.sol # Smart contract
├── scripts/
│ └── deploy.js # Deployment script for Sepolia
├── index.html # Frontend application
├── hardhat.config.js # Hardhat configuration
├── .solhint.json # Solhint linting rules
├── .env # Environment variables (not tracked)
├── .gitignore # Git exclusions
└── README.md

---

## Key Features

### Smart Contract (`Voting.sol`)

- `onlyOwner` modifier restricts administrative functions
- `isVotingOpen` modifier enforces a deadline using `block.timestamp`
- Double-vote prevention via `mapping(address => bool) hasVoted`
- Custom errors (`AlreadyVoted`, `VotingNotOpen`, etc.) for gas efficiency
- Events (`VoteCast`, `VotingStarted`, `VotingClosed`) for on-chain audit trail
- `bytes32` for candidate names (gas-optimised over `string`)
- Full NatSpec documentation

### Frontend (`index.html`)

- MetaMask wallet integration via ethers.js Web3Provider
- Network detection (verifies user is on Sepolia chainId 11155111)
- Full transaction lifecycle feedback (submitted → confirming → confirmed)
- Live vote bars with percentage visualisation
- Real-time event listener via `contract.on("VoteCast")`
- Graceful error handling for user rejection, already-voted, and wrong network

---

## Installation and Setup

### Prerequisites

- **Node.js** v22 (LTS) — not v23 (Hardhat incompatible)
- **npm** (included with Node.js)
- **MetaMask** browser extension
- **Google Chrome** (or any Chromium-based browser)

### Step 1 — Clone the Repository

```bash
git clone https://github.com/alfredrejipaul/voting-dapp.git
cd voting-dapp
```

### Step 2 — Install Dependencies

```bash
npm install
```

### Step 3 — Environment Variables

Create a `.env` file in the project root with:
SEPOLIA_RPC_URL=https://gateway.tenderly.co/public/sepolia
PRIVATE_KEY=your_metamask_private_key_here

**Note:** The private key is only required for deploying a new contract. For testing the existing deployment, you only need MetaMask.

### Step 4 — Compile the Contract

```bash
npx hardhat compile
```

### Step 5 — (Optional) Deploy a Fresh Contract

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

This will print a new contract address. Update the `CONTRACT_ADDRESS` constant in `index.html` if you deploy a new instance.

### Step 6 — Run the Frontend

The frontend must be served over HTTP (not opened as `file://`) for MetaMask to inject properly.

Install `live-server` globally (one-time):

```bash
npm install -g live-server
```

Run it from the project root:

```bash
live-server
```

The application will open automatically at `http://127.0.0.1:8080`.

### Step 7 — Use the Application

1. Ensure MetaMask is switched to the **Sepolia** network
2. Fund your MetaMask wallet with Sepolia ETH from a faucet such as:
   - https://cloud.google.com/application/web3/faucet/ethereum/sepolia
3. Click **Connect MetaMask** in the frontend
4. Click **Vote** next to your chosen candidate
5. Approve the transaction in the MetaMask popup
6. Wait ~12 seconds for block confirmation

---

## Verifying the Deployment

The deployed contract can be inspected on Sepolia Etherscan:

https://sepolia.etherscan.io/address/0x96CCf9ff606a10a716B2bD4fdD16C218b6476123

---

## Code Quality

Solhint is integrated for Solidity static analysis. The configuration is in `.solhint.json`.

Run the linter:

```bash
npx solhint 'contracts/**/*.sol'
```

The final contract passes with **0 errors and 0 warnings**.

---

## Notes

- All sensitive credentials (`PRIVATE_KEY`, `SEPOLIA_RPC_URL`) are stored in `.env` and excluded via `.gitignore`. The repository does not expose any keys.
- The git commit history reflects incremental development: initial scaffolding → contract implementation → Solhint integration → iterative warning resolution → frontend development.
- The frontend does not require a build step. It is a single self-contained HTML file using CDN-loaded ethers.js, consistent with the DApp architecture described in the module (JavaScript application served from any static host).

---

## References

- Murthy, M. (2017). _ethereum_voting_dapp_ [Source code]. GitHub. https://github.com/maheshmurthy/ethereum_voting_dapp
- Yuan, M.J. (2019). _Building Blockchain Apps_. Addison-Wesley Professional.
- Solidity Documentation v0.8.24 — https://docs.soliditylang.org
- Hardhat Documentation — https://hardhat.org/docs
- ethers.js v5 Documentation — https://docs.ethers.org/v5
