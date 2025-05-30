import { ethers } from "./ethers-6.7.esm.min.js"
import { abi, contractAddress } from "./constants.js"

const connectButton = document.getElementById("connectButton")
const withdrawButton = document.getElementById("withdrawButton")
const fundButton = document.getElementById("fundButton")
const balanceButton = document.getElementById("balanceButton")
const ethAmountInput = document.getElementById("ethAmount")
const statusMessage = document.getElementById("statusMessage")

connectButton.onclick = connect
withdrawButton.onclick = withdraw
fundButton.onclick = fund
balanceButton.onclick = getBalance

function setStatus(message, isError = false) {
  statusMessage.textContent = message
  statusMessage.style.color = isError ? "#dc2626" : "#2563eb"
}

function setLoading(button, isLoading) {
  button.disabled = isLoading
  button.style.opacity = isLoading ? "0.6" : "1"
}

async function connect() {
  if (typeof window.ethereum !== "undefined") {
    try {
      await ethereum.request({ method: "eth_requestAccounts" })
      connectButton.innerHTML = "Connected"
      const accounts = await ethereum.request({ method: "eth_accounts" })
      setStatus(`Connected: ${accounts[0].slice(0, 6)}...${accounts[0].slice(-4)}`)
    } catch (error) {
      console.error(error)
      setStatus("Connection rejected", true)
    }
  } else {
    connectButton.innerHTML = "Install MetaMask"
    setStatus("MetaMask not found", true)
  }
}

async function withdraw() {
  if (typeof window.ethereum === "undefined") {
    withdrawButton.innerHTML = "Install MetaMask"
    setStatus("MetaMask not found", true)
    return
  }

  setLoading(withdrawButton, true)
  setStatus("Processing withdrawal...")

  try {
    const provider = new ethers.BrowserProvider(window.ethereum)
    await provider.send("eth_requestAccounts", [])
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)

    const tx = await contract.withdraw()
    await tx.wait(1)
    setStatus("Withdrawal successful ✅")
  } catch (error) {
    console.error(error)
    setStatus("Withdrawal failed ❌", true)
  }

  setLoading(withdrawButton, false)
}

async function fund() {
  if (typeof window.ethereum === "undefined") {
    fundButton.innerHTML = "Install MetaMask"
    setStatus("MetaMask not found", true)
    return
  }

  const ethAmount = ethAmountInput.value
  if (!ethAmount || isNaN(ethAmount) || parseFloat(ethAmount) <= 0) {
    setStatus("Please enter a valid ETH amount", true)
    return
  }

  setLoading(fundButton, true)
  setStatus(`Funding with ${ethAmount} ETH...`)

  try {
    const provider = new ethers.BrowserProvider(window.ethereum)
    await provider.send("eth_requestAccounts", [])
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)

    const tx = await contract.fund({ value: ethers.parseEther(ethAmount) })
    await tx.wait(1)

    setStatus("Funding successful ✅")
    ethAmountInput.value = ""
  } catch (error) {
    console.error(error)
    setStatus("Funding failed ❌", true)
  }

  setLoading(fundButton, false)
}

async function getBalance() {
  if (typeof window.ethereum === "undefined") {
    balanceButton.innerHTML = "Install MetaMask"
    setStatus("MetaMask not found", true)
    return
  }

  setLoading(balanceButton, true)
  setStatus("Fetching contract balance...")

  try {
    const provider = new ethers.BrowserProvider(window.ethereum)
    const balance = await provider.getBalance(contractAddress)
    setStatus(`Balance: ${ethers.formatEther(balance)} ETH`)
  } catch (error) {
    console.error(error)
    setStatus("Failed to get balance ❌", true)
  }

  setLoading(balanceButton, false)
}
