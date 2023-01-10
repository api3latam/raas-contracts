import { airnodeLogicSetup } from "../../helpers/fixtures";
import { shouldBehaveLikeAirnodeLogic } from "./airnodeLogic.behavior";

describe("AirnodeLogic Tests", () => {
    describe("Behavior Tests", async () => {
        context("ShouldBehaveLikeAirnodeLogic", async () => {
            await shouldBehaveLikeAirnodeLogic(
                airnodeLogicSetup
            );
        });
    });
})