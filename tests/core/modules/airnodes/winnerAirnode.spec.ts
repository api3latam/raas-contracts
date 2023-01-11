import { airnodeSetupFixture,
    airnodeLogicSetup } from "../../../helpers/fixtures";
import { getBytesSelector } from "../../../helpers/utils";
import { shouldBehaveLikeAirnodeLogic } from "../../base/airnodeLogic.behavior";
import { shouldBehaveLikeWinnerAirnode } from "./winnerAirnode.behavior";
import { WinnerAirnode__factory,
    WinnerAirnode} from "../../../../typechain";

export interface setupFixture extends airnodeSetupFixture {
    winnerAirnode: WinnerAirnode
}

const qrngData: {
    [index: string]: string
} = require("../../../../qrng.json");

describe("WinnerAirnode Tests", () => {
    async function setupFunction(): Promise<setupFixture> {
        const {
            airnodeLogic,
            eventsLib,
            rrpAddress,
            deployer,
            mock,
            sponsor,
            derived
        } = await airnodeLogicSetup()

        const winnerAirnode = await new WinnerAirnode__factory(deployer).deploy(
            rrpAddress
        );

        await (await winnerAirnode.setRequestParameters(
            mock.address,
            sponsor.address,
            derived.address
        )).wait()

        await(await winnerAirnode.addNewEndpoint(
            qrngData["endpointIdUint256"],
            "getIndividualWinner(bytes32,bytes)"
        )).wait()

        return {
            airnodeLogic,
            eventsLib,
            rrpAddress,
            deployer,
            mock,
            sponsor,
            derived,
            winnerAirnode
        }
    }

    describe("Behavior Tests", async() => {
        describe("shouldBehaveLikeAirnodeLogic", async () => {
            await shouldBehaveLikeAirnodeLogic(
                airnodeLogicSetup
            );
        });
        describe("shouldBehaveLikeWinnerAirnode", async () => {
            await shouldBehaveLikeWinnerAirnode(
                setupFunction
            );
        });
    });
})