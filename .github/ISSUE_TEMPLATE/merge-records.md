---
name: Merge records
about: Checklists for merge records requests
title: ''
labels: ''
assignees: ''

---

### Merge Resource Records

Merging resource records in ASpace requires a bit of a workaround for two reasons:
1. the available endpoint doesn't retain all collection-level fields
2. another API endpoint (transfer ao's to a resource) is broken

Collections being merged:

Comments:

Checklist:

- [ ] create a new series-level ao in the receiving resource and copy over all the fields from the incoming resource record (Ruby)
- [ ] add external identifiers with the old call #
- [ ] merge the incoming resource into the receiving resource (UI or Ruby)
- [ ] move the incoming ao's into the new series (UI)
- [ ] calculate new collection dates (ASpace calculator)
- [ ] calculate new collection extents (do not use ASpace calculator, it's broken)
- [ ] add revision note
- [ ] update Finding Aid data (title, date)
- [ ] update collection-level Agent, Subject links
- [ ] merge abstract and scope notes at the collection level
- [ ] delete abstracts at the ao level
- [ ] change wording in scope notes at the ao level
- [ ] update physlocs at the collection level
- [ ] update accessrestrict and userestrict at the collection level
- [ ] delete accessrestrict, userestrict at the ao level unless restrictions apply
- [ ] review relatedmaterials
- [ ] review existence and location of copies
- [ ] update prefercite
- [ ] LAE: add unpublished series for microfilm on the collection level
