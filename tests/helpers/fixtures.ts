import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Events__factory, 
    Events, AirnodeLogic,
    MockAirnodeLogic__factory,
    MockAirnodeRrpV0__factory } from "../../typechain";

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

export interface airnodeSetupFixture {
    airnodeLogic: AirnodeLogic,
    eventsLib: Events,
    rrpAddress: string,
    deployer: SignerWithAddress,
    mock: SignerWithAddress,
    sponsor: SignerWithAddress,
    derived: SignerWithAddress
}

export async function airnodeLogicSetup (
): Promise<airnodeSetupFixture> {
    const { 
        deployer, 
        user: mock,
        external: sponsor,
        extra: derived } = await loadFixture(getAccounts);
    const eventsLib = await loadFixture(getEventsLibrary);

    const airnodeRrp = await new MockAirnodeRrpV0__factory(deployer).deploy();
    const airnodeLogic = await new MockAirnodeLogic__factory(deployer
        ).deploy(
        airnodeRrp.address
    );

    return { airnodeLogic, eventsLib, 
        rrpAddress: airnodeRrp.address,
        deployer, mock, sponsor, derived }
}
