import { ethers, waffle } from "hardhat";
import { MyMetaVerse } from "../typechain/MyMetaVerse";
import { Loot } from "../typechain/Loot";
import { SyntheticLoot } from "../typechain/SyntheticLoot";
import { DefaultUriTheme } from "../typechain/DefaultUriTheme";
import { expect } from "./inc/expect";

import { BigNumber } from "ethers";
const BN = BigNumber.from

describe("Test", () => {
  const [wallet, other] = waffle.provider.getWallets();
  //////////////
  let loot: Loot;
  const lootFixture = async () => {
    const factory = await ethers.getContractFactory("Loot");
    return (await factory.deploy()) as Loot;
  };
  before("deploy Loot", async () => {
    loot = await waffle.loadFixture(lootFixture);
  });
  //////////////
  let myMetaVerse: MyMetaVerse;
  const MMVfixture = async () => {
    const factory = await ethers.getContractFactory("MyMetaVerse");
    return (await factory.deploy()) as MyMetaVerse;
  };
  before("deploy MyMetaVerse", async () => {
    myMetaVerse = await waffle.loadFixture(MMVfixture);
  });
  ////////////
  let syntheticLoot: SyntheticLoot;
  const syntheticLootFixture = async () => {
    const factory = await ethers.getContractFactory("SyntheticLoot");
    return (await factory.deploy()) as SyntheticLoot;
  };
  before("deploy SyntheticLoot", async () => {
    syntheticLoot = await waffle.loadFixture(syntheticLootFixture);
  });
  //////////////
  let defaultUriTheme: DefaultUriTheme;
  const defaultUriThemeFixture = async () => {
    const factory = await ethers.getContractFactory("DefaultUriTheme");
    return (await factory.deploy(myMetaVerse.address)) as DefaultUriTheme;
  };
  before("deploy DefaultUriTheme", async () => {
    defaultUriTheme = await waffle.loadFixture(defaultUriThemeFixture);
  });
  //////////////

  it("Loot claim", async () => {
    const receipt = await loot.claim("1");
  });

  it("Loot getWeapon", async () => {
    const receipt = await loot.getWeapon("1");
    console.log(receipt.toString())
  });

  it("MyMetaVerse newGame", async () => {
    const receipt = await myMetaVerse.newGame("1","LOOT","LOOT",syntheticLoot.address);
  });

  it("MyMetaVerse addUriTheme", async () => {
    const receipt = await myMetaVerse.addUriTheme("1",defaultUriTheme.address);
  });

  it("SyntheticLoot init", async () => {
    const receipt = await syntheticLoot.init(
      loot.address,
      myMetaVerse.address
    );
  });

  it("Loot approve", async () => {
    const receipt = await loot.approve(syntheticLoot.address,"1");
  });

  it("myMetaVerse claim", async () => {
    const receipt = await myMetaVerse.claim();
    const balance = await myMetaVerse["balanceOf(address)"](wallet.address);
    expect(BN('1')).to.eq(balance)
    const tokenid = await myMetaVerse.tokenOfOwnerByIndex(wallet.address,"0");
    expect(BN('1')).to.eq(tokenid)
  });

  it("Loot transferFrom", async () => {
    const receipt = await loot.transferFrom(wallet.address,syntheticLoot.address,"1");
  });

  it("SyntheticLoot synthetic", async () => {
    const receipt = await syntheticLoot.synthetic("1","1");
    // console.log(await receipt.wait())
  });

  it("SyntheticLoot tokenURI", async () => {
    const receipt = await myMetaVerse.textOf("1","10001");
    console.log(receipt.toString())
  });

  it("MyMetaVerse newGame", async () => {
    const receipt = await myMetaVerse.newGame("2","LOOT2","LOOT2",wallet.address);
    const gamesId = await myMetaVerse.gamesId(wallet.address);
    expect(BN('2')).to.eq(gamesId)
  });

  it("MyMetaVerse gameMint", async () => {
    const receipt = await myMetaVerse.gameMint("1","LOOT2Attr","LOOT2Attr","");
    const name = await myMetaVerse["name(uint256)"]("20001");
    expect("LOOT2Attr").to.eq(name)
  });

  it("MyMetaVerse gameAttach", async () => {
    const receipt = await myMetaVerse.gameAttach("1","1","0","0x436c7562",false);
    const name = await myMetaVerse.textOf("1","20001");
    console.log(name.toString())
    expect("0x436c7562").to.eq(name)
  });

  it("MyMetaVerse tokenURI", async () => {
    const receipt = await myMetaVerse.tokenURI("1");
    console.log(receipt.toString())
  });
});
