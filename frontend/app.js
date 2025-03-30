const tokenABI = [
    "function balanceOf(address) view returns (uint256)",
    "function transfer(address to, uint256 amount) returns (bool)",
    "function decimals() view returns (uint8)",
    "function symbol() view returns (string)",
    "function getCurrentFeePercentage() view returns (uint256)"
];

// Thay bằng địa chỉ hợp đồng của bạn
const tokenAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Ví dụ

let provider;
let signer;
let tokenContract;

async function connectMetaMask() {
    if (window.ethereum) {
        try {
            await window.ethereum.request({ method: "eth_requestAccounts" });
            provider = new ethers.BrowserProvider(window.ethereum);
            signer = await provider.getSigner();
            const account = await signer.getAddress();
            document.getElementById("account").innerText = account;

            tokenContract = new ethers.Contract(tokenAddress, tokenABI, signer);
            await updateBalance(account);
            await updateFee();
        } catch (error) {
            console.error("Error connecting to MetaMask:", error);
            alert("Failed to connect!");
        }
    } else {
        alert("Please install MetaMask!");
    }
}

async function updateBalance(account) {
    const balance = await tokenContract.balanceOf(account);
    const decimals = await tokenContract.decimals();
    const symbol = await tokenContract.symbol();
    const formattedBalance = ethers.formatUnits(balance, decimals);
    document.getElementById("balance").innerText = `${formattedBalance} ${symbol}`;
}

async function updateFee() {
    const feePercentage = await tokenContract.getCurrentFeePercentage();
    const formattedFee = (feePercentage / 100).toFixed(2); // Chuyển sang phần trăm
    document.getElementById("currentFee").innerText = formattedFee;
}

async function transferTokens() {
    const recipient = document.getElementById("recipient").value;
    const amount = document.getElementById("amount").value;
    if (!recipient || !amount) {
        alert("Please enter recipient address and amount!");
        return;
    }

    try {
        const decimals = await tokenContract.decimals();
        const parsedAmount = ethers.parseUnits(amount, decimals);
        const tx = await tokenContract.transfer(recipient, parsedAmount);
        await tx.wait();
        alert("Transfer successful! Owner received fee.");
        await updateBalance(await signer.getAddress());
        await updateFee();
    } catch (error) {
        console.error("Transfer failed:", error);
        alert("Transfer failed!");
    }
}

document.getElementById("connectButton").addEventListener("click", connectMetaMask);
document.getElementById("transferButton").addEventListener("click", transferTokens);
