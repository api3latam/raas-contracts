import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { deriveEndpointId } from "@api3/airnode-admin";
import { matchEvent } from "../../helpers/utils";
import { AirnodeLogic, Events } from "../../../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

// Pending to add base tests from `RrpRequesterV0` parent contract.

export async function shouldBehaveLikeAirnodeLogic(
    airnodeLogic: AirnodeLogic,
    eventsLib: Events,
    wallets: {
        mock: SignerWithAddress,
        sponsor: SignerWithAddress,
        derived: SignerWithAddress
    }
) {
    describe("AirnodeLogic Behaviour", async() => {
        async function setupFixture() {
            const mock = wallets["mock"];
            const sponsor = wallets["sponsor"];
            const derived = wallets["derived"];

            return { mock, sponsor, derived };
        }

        describe("Should correctly set and update parameters", async() => {
            it("Should emit expected event and show public updated values", async() => {
                const { mock, 
                    sponsor, derived } = await loadFixture(setupFixture);

                const txRequestParam = await airnodeLogic.setRequestParameters(
                    mock.address,
                    sponsor.address,
                    derived.address
                );
                const receiptRequestParam = await txRequestParam.wait();
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

            it("Should allow adding new endpoints", async() => {
                const testId = await deriveEndpointId("airnodeLogic", "testFunction");
                const testFunction = "testFunction(address,uint256)";
                const testSelector = ethers.utils.hexDataSlice(
                    ethers.utils.keccak256(
                        ethers.utils.toUtf8Bytes(
                            testFunction
                    )),
                    0,
                    4
                );

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
            })
        })
    })
}