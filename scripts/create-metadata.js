const DnD = artifacts.require('DungeonsAndDragonsCharacter');
const fs = require('fs');

const metadataTemplate = {
  name: '',
  description: '',
  image: '',
  attributes: [
    {
      trait_type: 'Strength',
      value: 0,
    },
    {
      trait_type: 'Dexterity',
      value: 0,
    },
    {
      trait_type: 'Constitution',
      value: 0,
    },
    {
      trait_type: 'Intelligence',
      value: 0,
    },
    {
      trait_type: 'Wisdom',
      value: 0,
    },
    {
      trait_type: 'Charisma',
      value: 0,
    },
    {
      trait_type: 'Experience',
      value: 0,
    },
  ],
};
module.exports = async (callabck) => {
  const dnd = await DnD.deployed();
  length = await dnd.getNumberOfCharacters();
  index = 0;
  while (index < length) {
    console.log(
      "Let's get the overview of your character " + index + ' of ' + length
    );
    let characterMetadata = metadataTemplate;
    let characterOverview = await dnd.characters(index);
    index++;
    characterMetadata.name = characterOverview.name;
    if (
      fs.existsSync(
        'metadata/' +
          characterMetadata['name'].toLowerCase().replace(/\s/g, '-') +
          '.json'
      )
    ) {
      console.log('test');
      continue;
    }
    console.log(characterMetadata['name']);
    characterMetadata['attributes'][0]['value'] =
      characterOverview['str']['words'][0];
    characterMetadata['attributes'][1]['value'] =
      characterOverview['dex']['words'][0];
    characterMetadata['attributes'][2]['value'] =
      characterOverview['con']['words'][0];
    characterMetadata['attributes'][3]['value'] =
      characterOverview['inte']['words'][0];
    characterMetadata['attributes'][4]['value'] =
      characterOverview['wis']['words'][0];
    characterMetadata['attributes'][5]['value'] =
      characterOverview['cha']['words'][0];
    filename =
      'metadata/' + characterMetadata['name'].toLowerCase().replace(/\s/g, '-');
    let data = JSON.stringify(characterMetadata);
    fs.writeFileSync(filename + '.json', data);
  }
  callback(dnd);
};
