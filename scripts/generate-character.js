const DnD = artifacts.require('DungeonsAndDragonsCharacter');

module.exports = async (callback) => {
  const dnd = await DnD.deployed();
  console.log(`Chreating request on contract: ${dnd.address}`);
  const tx = await dnd.requestNewRandomCharacter('The Chainlink Knight');
  const tx2 = await dnd.requestNewRandomCharacter('The Chainlink Elf');
  const tx3 = await dnd.requestNewRandomCharacter('The Chainlink Wizard');
  const tx4 = await dnd.requestNewRandomCharacter('The Chainlink Orc');
  callabck(tx.tx);
};
