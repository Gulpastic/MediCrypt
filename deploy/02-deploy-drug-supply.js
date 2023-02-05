const { getNamedAccounts, deployments, network } = require("hardhat")
const { developmentChains, VERIFICATION_BLOCK_CONFIRMATIONS } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS

    log(
        "------------------------------------------------------------------------------------------------"
    )

    const arguments = []
    const drugSupply = await deploy("DrugSupply", {
        from: deployer,
        args: arguments,
        log: true,
        // we need to wait if on a live network so we can verify properly
        waitConfirmations: waitBlockConfirmations || 1,
    })
    log(`Digital prescription deployed at address: ${drugSupply.address}`)
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("verifying...")
        await verify(drugSupply.address)
    }
    log(
        "------------------------------------------------------------------------------------------------"
    )
}

module.exports.tags = ["all", "dp"]
