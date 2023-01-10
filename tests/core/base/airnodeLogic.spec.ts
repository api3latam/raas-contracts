import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { getAccounts, 
    getEventsLibrary } from "../../helpers/fixtures";
import { MockAirnodeLogic__factory,
    MockAirnodeRrpV0__factory,
    Events, AirnodeLogic } from "../../../typechain";
import { shouldBehaveLikeAirnodeLogic } from "./airnodeLogic.behavior";

export interface setupFunction {
    airnodeLogic: AirnodeLogic,
    eventsLib: Events,
    mock: SignerWithAddress,
    sponsor: SignerWithAddress,
    derived: SignerWithAddress
}

describe("AirnodeLogic Tests", () => {
    async function setupFunction(): Promise<setupFunction> {
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
            mock, sponsor, derived }
    }
    describe("Behavior Tests", async () => {
        context("ShouldBehaveLikeAirnodeLogic", async () => {
            await shouldBehaveLikeAirnodeLogic(
                setupFunction
            );
        });
    });
})