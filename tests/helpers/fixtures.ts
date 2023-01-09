import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { Events__factory } from "../../typechain";

/**
 * Fixture to get accounts from hardhat network.
 * 
 * @returns An object containing 4 wallets for usage.
 */
export async function getAccounts() {
    const [ deployer, user, external, extra ] = await ethers.getSigners();
    return { deployer, user, external, extra }
}

/**
 * Fixture to get `Events` library contract.
 * 
 * @notice Event library deployment is only needed for testing
 * and is not reproduced in the live environment.
 * @returns An instance of Events contract.
 */
export async function getEventsLibrary() {
    const { deployer } = await loadFixture(getAccounts)
    return await new Events__factory(deployer).deploy();
}
