const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, party, constituency) => {
  qualifier = {
    P2937: meta.legislature.term.id,
    P4100: party,
    P768:  constituency,
  }

  source = {
    P143:  'Q328',
    P4656: 'https://en.wikipedia.org/w/index.php?title=List_of_House_members_of_the_43rd_Parliament_of_Canada&oldid=1042394684',
    P813:  new Date().toISOString().split('T')[0],
  }

  return {
    id,
    claims: {
      P39: {
        value:      meta.legislature.member,
        qualifiers: qualifier,
        references: source,
      }
    }
  }
}
