const { ethers, upgrades } = require("hardhat");

const PROXY = "0x935b177AE396eDD723Fee35f5Ccda3F45B88a984";

async function main() {
  const PizzaV2 = await ethers.getContractFactory("PizzaV2");
  const pizza = await PizzaV2.attach(PROXY);
  console.log("Pizza Proxy attached");

//   await pizza.refillSlice()
  console.log(await pizza.slices())
  console.log(await pizza.pizzaVersion())
}

main();
