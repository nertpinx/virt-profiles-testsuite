= testsuite for the virt-profiles REST API

License: Apache v2
(C) 2018 the virt-profiles authors


=== content
1. curl command lines
2. request/response documents

=== layout
The testsuite is organized as follows.
1. there is a top-level directory in the repo root called "routes"
2. REST routes starts from the "routes" directory. Example:

     https://virt-profiles/profiles

   maps to
   virt-profiles-testsuite.git/routes/profiles
3. in each route directory there is another subdirectory named \_VERB for each
   supported http verb. Example

     https://virt-profiles/profiles/\_GET

4. in each per-verb subdirectory, we have pairs called XXX\_request\_\* and XXX\_response\_CODE\_\*
   where:
   - XXX is just a sequential number
   - any string after "request" is just for human consumption (e.g. to make easier to distinguish test cases)
   - requests and responses are matched by sequential number - always keep them in pairs!
   - for responses, the HTTP return code is encoded in the file name - "CODE"
   - the actual body of the response is the body of the file

   Example:
   - 000\_request.json
   - 000\_response\_200.json

   Finally, in each subdirectory CURL.sh file will illustrate the template command line to send the requests.
