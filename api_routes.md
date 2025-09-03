# REST API Documentation

This document provides a detailed description of the REST API endpoints available in the application.

---

## Agents API

File: `src/solace_agent_mesh/gateway/http_sse/routers/agents.py`

### Get Discovered Agents

Retrieves a list of all currently discovered A2A agents.

- **Method:** `GET`
- **Path:** `/api/v1/agents`
- **Authentication:** Required (Bearer Token).

**Request**

No parameters.

**Responses**

- **`200 OK`**

  A successful response will return a JSON array of `AgentCard` objects.

  **`AgentCard` Schema:**
  ```json
  {
    "name": "string",
    "display_name": "string",
    "description": "string",
    "url": "string",
    "provider": {
      "organization": "string",
      "url": "string"
    },
    "version": "string",
    "documentationUrl": "string",
    "capabilities": {
      "streaming": "boolean",
      "pushNotifications": "boolean",
      "stateTransitionHistory": "boolean"
    },
    "authentication": {
      "schemes": ["string"],
      "credentials": "string"
    },
    "defaultInputModes": ["string"],
    "defaultOutputModes": ["string"],
    "skills": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "tags": ["string"],
        "examples": ["string"],
        "inputModes": ["string"],
        "outputModes": ["string"]
      }
    ]
  }
  ```

- **`500 Internal Server Error`**
  ```json
  {
    "detail": "Internal server error retrieving agent list."
  }
  ```

---

## Artifacts API

File: `src/solace_agent_mesh/gateway/http_sse/routers/artifacts.py`

### List Artifacts

Retrieves detailed information for all artifacts for the current user session.

- **Method:** `GET`
- **Path:** `/api/v1/artifacts/`
- **Authentication:** Required (Bearer Token).

**Responses**

- **`200 OK`**
  Returns a JSON array of `ArtifactInfo` objects.

  **`ArtifactInfo` Schema:**
  ```json
  {
    "filename": "string",
    "mime_type": "string",
    "size": "integer",
    "last_modified": "string (date-time)",
    "description": "string",
    "schema": {},
    "uri": "string",
    "version": "integer | 'latest'",
    "version_count": "integer"
  }
  ```

### Upload Artifact

Uploads a file to create a new version of an artifact.

- **Method:** `POST`
- **Path:** `/api/v1/artifacts/{filename}`
- **Authentication:** Required (Bearer Token).

**Path Parameters**

- `filename` (string, required): The name of the artifact to create or update.

**Request Body**

- **Content-Type:** `multipart/form-data`
- **Parts:**
  - `upload_file` (file, required): The file content to upload.
  - `metadata_json` (string, optional): A JSON string of artifact metadata.

**Responses**

- **`201 Created`**
  ```json
  {
    "filename": "string",
    "data_version": "integer",
    "metadata_version": "integer",
    "mime_type": "string",
    "size": "integer",
    "message": "string",
    "status": "string"
  }
  ```

### Get Latest Artifact

Retrieves the content of the latest version of a specific artifact.

- **Method:** `GET`
- **Path:** `/api/v1/artifacts/{filename}`
- **Authentication:** Required (Bearer Token).

**Path Parameters**

- `filename` (string, required): The name of the artifact.

**Responses**

- **`200 OK`**
  Returns the file content with the appropriate `Content-Type` header.

### Delete Artifact

Deletes an artifact and all its versions.

- **Method:** `DELETE`
- **Path:** `/api/v1/artifacts/{filename}`
- **Authentication:** Required (Bearer Token).

**Path Parameters**

- `filename` (string, required): The name of the artifact to delete.

**Responses**

- **`204 No Content`**
  The artifact was deleted successfully.

### List Artifact Versions

Retrieves a list of available versions for a specific artifact.

- **Method:** `GET`
- **Path:** `/api/v1/artifacts/{filename}/versions`
- **Authentication:** Required (Bearer Token).

**Path Parameters**

- `filename` (string, required): The name of the artifact.

**Responses**

- **`200 OK`**
  Returns a JSON array of integers representing the versions.
  ```json
  [1, 2, 3]
  ```

### Get Specific Artifact Version

Retrieves the content of a specific version of an artifact.

- **Method:** `GET`
- **Path:** `/api/v1/artifacts/{filename}/versions/{version}`
- **Authentication:** Required (Bearer Token).

**Path Parameters**

- `filename` (string, required): The name of the artifact.
- `version` (string, required): The version number to retrieve, or `'latest'`.

**Responses**

- **`200 OK`**
  Returns the file content with the appropriate `Content-Type` header.

---

## Tasks API

File: `src/solace_agent_mesh/gateway/http_sse/routers/tasks.py`

### Submit Streaming Task

Submits a streaming task request to an agent. The client should then connect to the SSE endpoint using the returned `taskId`.

- **Method:** `POST`
- **Path:** `/api/v1/tasks/subscribe`
- **Authentication:** Required (Bearer Token).

**Request Body**

- **Content-Type:** `multipart/form-data`
- **Parts:**
  - `agent_name` (string, required): The name of the agent to send the task to.
  - `message` (string, required): The message or prompt for the agent.
  - `files` (file, optional): One or more files to include with the task. Can be specified multiple times.

**Responses**

- **`200 OK`**
  ```json
  {
    "jsonrpc": "2.0",
    "id": "string",
    "result": {
      "taskId": "string"
    }
  }
  ```

### Cancel Task

Sends a cancellation request for a specific task. This is an asynchronous operation.

- **Method:** `POST`
- **Path:** `/api/v1/tasks/cancel`
- **Authentication:** Required (Bearer Token).

**Request Body**

- **Content-Type:** `application/json`
- **Schema:**
  ```json
  {
    "agent_name": "string",
    "task_id": "string"
  }
  ```

**Responses**

- **`202 Accepted`**
  The cancellation request has been sent.
  ```json
  {
    "message": "Cancellation request sent"
  }
  ```

---

## SSE API

File: `src/solace_agent_mesh/gateway/http_sse/routers/sse.py`

### Subscribe to Task Events

Establishes a Server-Sent Events (SSE) connection to receive real-time updates for a specific task.

- **Method:** `GET`
- **Path:** `/api/v1/sse/subscribe/{task_id}`
- **Authentication:** Can be provided via Bearer token in query parameter `?token=...`.

**Path Parameters**

- `task_id` (string, required): The ID of the task to subscribe to.

**Responses**

- **`200 OK`**
  An SSE stream is opened. Events will be sent as they occur. The events are `status_update`, `artifact_update`, `final_response`, and `error`.

---

## Other APIs

### Get App Configuration

- **Method:** `GET`
- **Path:** `/api/v1/config`
- **Description:** Provides configuration settings for the frontend.
- **May require CSRF token.**

### Get CSRF Token

- **Method:** `GET`
- **Path:** `/api/v1/csrf-token`
- **Description:** Generates and returns a CSRF token.

### Create New Session

- **Method:** `POST`
- **Path:** `/api/v1/sessions/new`
- **Description:** Forces the creation of a new A2A session.

### Get Current Session

- **Method:** `GET`
- **Path:** `/api/v1/sessions/current`
- **Description:** Returns information about the current session.
