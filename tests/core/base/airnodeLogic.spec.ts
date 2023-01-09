import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { getAccounts, 
    getEventsLibrary } from "../../helpers/fixtures";
import { MockAirnodeLogic__factory,
    MockAirnodeRrpV0__factory } from "../../../typechain";
import { shouldBehaveLikeAirnodeLogic } from "./airnodeLogic.behavior";

describe("AirnodeLogic Tests", async() => {
    it("Should behave like an AirnodeLogic contract", async() => {
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

        await shouldBehaveLikeAirnodeLogic(
            airnodeLogic,
            eventsLib,
            {
                mock,
                sponsor,
                derived
            }
        );
    });
});