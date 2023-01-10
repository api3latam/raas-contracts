import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
// import { ethers } from "hardhat";
import { deriveEndpointId } from "@api3/airnode-admin";
import { matchEvent, getBytesSelector } from "../../helpers/utils";
import { airnodeSetupFixture } from "../../helpers/fixtures";

// Pending to add base tests from `RrpRequesterV0` parent contract.

export async function shouldBehaveLikeAirnodeLogic(
    fixtureSetup: any
) {
    it("requestParameters", async() => {
        const { airnodeLogic, eventsLib, 
            mock, sponsor, derived }: airnodeSetupFixture = await loadFixture(fixtureSetup);

        const receiptRequestParam = await (await airnodeLogic.setRequestParameters(
            mock.address,
            sponsor.address,
            derived.address
        )).wait();

        await matchEvent(
            receiptRequestParam,
            "SetRequestParameters",
            eventsLib,
            [mock.address,
            sponsor.address,
            derived.address],
            airnodeLogic.address
        );
        expect(await airnodeLogic.airnode())
            .to.equal(mock.address);
    });

    it("addNewEndpoint", async() => {
        const { airnodeLogic, eventsLib }: airnodeSetupFixture = 
            await loadFixture(fixtureSetup);

        const testId = await deriveEndpointId("airnodeLogic", "testFunction");
        const testFunction = "testFunction(address,uint256)";
        const testSelector = getBytesSelector(testFunction);

        const txAddEndpoint = await (await airnodeLogic.addNewEndpoint(
            testId,
            testFunction
        )).wait();

        await matchEvent(
            txAddEndpoint,
            "SetAirnodeEndpoint",
            eventsLib,
            [0,
            testId,
            testFunction,
            testSelector]
        );

        const firstEndpoint = await airnodeLogic.endpointsIds(0);
        expect(firstEndpoint[0]).to.equal(testId);
        expect(firstEndpoint[1]).to.equal(testSelector);
    });
}
