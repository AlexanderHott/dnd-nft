const DnD = artifacts.require('DungeonsAndDragonsCharacter');
const LinkTokenInterface = artifactrs.require('LinkTokenInterface');

/*
  This script is meant to assist with funding the requesting
  contract with LINK. It will send 1 LINK to the requesting
  contract for ease-of-use. Any extra LINK present on the contract
  can be retrieved by calling the withdrawLink() function.
*/

const payment = process.env.TRUFFLE_CL_BOX_PAYMENT || '3000000000000000000';

module.exports = async (callback) => {
  try {
    const dnd = DnD.deployed();

    const tokenAddress = await dnd.LinkToken();
    console.log('Chainlink Token Address: ', tokenAddress);

    const token = LinkTokenInterface.at(tokenAddress);
    console.log('Funding contract:', dnd.address);

    const tx = await token.transfer(dnd.address, payment);
    callabck(tx.tx);
  } catch (err) {
    callback(err);
  }
};
