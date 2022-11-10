## Central EGA Example Messages

Messages used in communication with the Central EGA Submission portal, so that files are visible in that portal.

### Inbox Messages

Upload message:
```
{
   "operation": "upload",
   "user":"john.smith@smth.org",
   "filepath":"somedir/encrypted.file.c4gh",
   "file_last_modified": 1668071942,
   "encrypted_checksums": [
      { "type": "md5", "value": "1a79a4d60de6718e8e5b326e338ae533"},
      { "type": "sha256", "value": "50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c"}
   ]
}
```

Remvove message:

```
{
   "operation": "remove",
   "user":"john.smith@smth.org",
   "filepath":"somedir/encrypted.file.c4gh",
}
```


Rename message:

```
{
   "operation": "remove",
   "user":"john.smith@smth.org",
   "filepath":"somedir/encrypted-new.file.c4gh",
   "oldpath": "somedir/encrypted.file.c4gh",
}
```

### Ingest Message

Message received from Central EGA to start ingestion at a Federated EGA node.

```
{
   "type": "ingest",
   "user":"john.smith@smth.org",
   "filepath":"somedir/encrypted.file.c4gh",
   "encrypted_checksums": [
      { "type": "md5", "value": "1a79a4d60de6718e8e5b326e338ae533"},
      { "type": "sha256", "value": "50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c"}
   ]
}
```

### Accession ID Message

Each file will receive an accession ID from Central EGA and this is done via a message sent from Central EGA to a Federated EGA node.

```
{
    "type": "accession",
    "user": "john.smith@smth.org",
    "filepath": "somedir/encrypted.file.c4gh",
    "accession_id": "EGAF00000123456",
    "decrypted_checksums": [ 
        { "type": "sha256", "value": "50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c" },
        { "type": "md5", "value": "1a79a4d60de6718e8e5b326e338ae533" }
    ]
}
```

### Dataset ID to Accession ID Mapping Message

```
{
   "type": "mapping",
   "user":"john.smith@smth.org",
   "dataset_id": "EGAD12345678901",
   "accession_ids": ["EGAF00000123456", "EGAF00000123457"]
}
```
