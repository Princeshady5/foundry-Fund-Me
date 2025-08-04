Here's a clear and professional `README.md` tailored for your **FundMe** project, following best practices for GitHub documentation:

---

````markdown
# FundMe Smart Contract

A decentralized crowdfunding smart contract built in Solidity and tested using Foundry. This project allows users to fund a contract with ETH, enforces a minimum funding value based on real-time USD conversion via Chainlink, and enables only the contract owner to withdraw funds.

## 🛠️ Tech Stack

- **Solidity** `^0.8.18`
- **Foundry** – for compilation, testing, and scripting
- **Chainlink** – for decentralized price feeds
- **MockV3Aggregator** – for testing price feed data

## 📂 Project Structure

```bash
.
├── src/
│   ├── FundMe.sol              # Main contract
│   └── Interactions.s.sol      # Script for simulating interaction
├── test/
│   ├── FundMeTest.t.sol        # Unit tests
│   └── interactionTest.t.sol   # Integration tests
├── script/
│   └── DeployFundMe.s.sol      # Deployment script
├── lib/
│   └── foundry-devops/         # External utility contracts
├── foundry.toml                # Foundry configuration
````

## ⚙️ Features

* Users can fund the contract with ETH.
* Minimum contribution enforced via Chainlink price feed (e.g., \$5 in ETH).
* Each funder is tracked in a mapping and array.
* Only the contract owner can withdraw funds.
* Withdraw function resets funders and transfers balance using `.call`.
* Includes `receive()` and `fallback()` to accept direct ETH transfers.

## 🧪 Testing

The contract is tested using Foundry with:

* Unit tests (e.g., correct funding, failure with low ETH, owner-only withdrawals).
* Integration tests (e.g., interaction with deployed scripts).
* Mocked Chainlink price feeds for full test isolation.

Run tests with verbose output:

```bash
forge test -vvvv
```

Run a specific test:

```bash
forge test --match-test testWithdrawWithASingleFunder
```

Check gas costs:

```bash
forge snapshot --match testWithdrawWithASingleFunder
```

## 🔐 Security Considerations

* Implements an `onlyOwner` modifier for restricted functions.
* Uses `.call` over `.send`/`.transfer` for safer ETH transfers.
* Custom `NotOwner()` error for gas efficiency over `require()`.

## 🚀 Deployment

To deploy using Foundry scripting:

```bash
forge script script/DeployFundMe.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY>
```

## 🤝 Contributing

Feel free to fork the project, suggest improvements, or create pull requests.

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

### 🙋‍♂️ Author

**Prince Matthew**
Solidity Developer & Blockchain Learner
📍 Follow my journey into smart contract development

```

---

Let me know if you'd like a version with badges (build, license, etc.), or tailored sections like “TODO” or “Known Issues.”
```
