import { expect } from "chai";
import { ethers, artifacts } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { matchEvent, 
    getBytesSelector, getEmittedArgument } from "../../../helpers/utils";
import { setupFixture } from "./winnerAirnode.spec";

export async function shouldBehaveLikeWinnerAirnode(
    fixtureSetup: any
) {

    it("Should request one winner successfully", async() => {
        const { winnerAirnode,
            mock, eventsLib }: setupFixture = await loadFixture(fixtureSetup);
        const getIndividualWinner = getBytesSelector(
            "getIndividualWinner(bytes32,bytes)");
        const newWinnerRequest = "NewWinnerRequest";

        const txRequestWinner = await (await winnerAirnode.requestWinners(
            getIndividualWinner,
            1,
            10
        )).wait();
        
        const requestId = getEmittedArgument(
            txRequestWinner,
            eventsLib,
            newWinnerRequest,
            0
        )

        await matchEvent (
            txRequestWinner,
            "NewWinnerRequest",
            eventsLib,
            [requestId,
            mock.address],
            winnerAirnode.address
        )
    });
}
