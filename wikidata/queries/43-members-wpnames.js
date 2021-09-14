const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT ?item ?name ?group ?party ?district ?constituency ?startdate ?enddate
         (STRAFTER(STR(?statement), '/statement/') AS ?psid)
    WHERE
    {
      ?item p:P39 ?statement .
      ?statement ps:P39 wd:${meta.legislature.member} ; pq:P2937 wd:${meta.legislature.term.id} .

      OPTIONAL { ?statement pq:P4100 ?group }
      OPTIONAL { ?statement pq:P768 ?district }
      OPTIONAL { ?statement pq:P580 ?startdate }
      OPTIONAL { ?statement pq:P582 ?enddate }

      OPTIONAL {
        ?statement prov:wasDerivedFrom ?ref .
        ?ref (pr:P854|pr:P4656) ?source FILTER CONTAINS(STR(?source), 'en.wikipedia.org')
        OPTIONAL { ?ref pr:P1810 ?sourceName }
      }
      OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "${meta.source.lang.code}") }
      BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

      SERVICE wikibase:label {
        bd:serviceParam wikibase:language "en".
        ?genderItem rdfs:label ?gender .
        ?group rdfs:label ?party .
        ?district rdfs:label ?constituency .
      }
    }
    # ${new Date().toISOString()}
    ORDER BY ?item ?startdate`
}
