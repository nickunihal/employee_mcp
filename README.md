# Employee MCP Server

A Ruby on Rails application that exposes employee management functionality through the **Model Context Protocol (MCP)**.

This is a hands-on learning project where I'm exploring how MCP works, how AI applications can interact with existing backend systems, and how to expose application data and functionality to AI assistants in a structured way.

## What I'm Building

The goal is to turn an existing employee management domain into an MCP server that AI clients can interact with.

Instead of allowing an AI assistant to directly access the application's database, the Rails application exposes specific tools, resources and prompts through MCP.

## Features

- **MCP Tools** – Expose employee-related operations such as searching employees, retrieving employee details and counting employees by department.
- **MCP Resources** – Expose structured information such as the department directory.
- **MCP Resource Templates** – Retrieve detailed employee profiles dynamically using employee identifiers.
- **MCP Prompts** – Provide reusable prompts for generating department employee reports and department overviews.
- **Dynamic Data Access** – Allow connected AI clients to retrieve information through defined MCP interfaces.

## Tech Stack

- Ruby
- Ruby on Rails 8
- PostgreSQL
- Model Context Protocol (MCP)
- Ruby MCP SDK

## Architecture

The Rails application acts as an MCP server and exposes employee management capabilities to external MCP clients.

```text
AI Client
    |
    | MCP Protocol
    |
    v
Employee MCP Server
    |
    +-- Tools
    |    +-- Search Employees
    |    +-- Get Employee
    |    +-- Employee Count
    |
    +-- Resources
    |    +-- Department Directory
    |
    +-- Resource Templates
    |    +-- Employee Profile
    |
    +-- Prompts
         +-- Department Employee Report
         +-- Department Overview
    |
    v
PostgreSQL
```

## Learning Objectives

Through this project, I'm exploring:

- Understanding the Model Context Protocol and its architecture.
- Building MCP servers using Ruby and Rails.
- Understanding the differences between MCP tools, resources, resource templates and prompts.
- Exposing existing application functionality to AI clients.
- Working with MCP transports and client-server communication.
- Designing structured interfaces between backend applications and AI systems.

## Project Status

This is an ongoing learning project. I'm gradually expanding its capabilities while experimenting with MCP concepts and integrating it with a separate AI assistant project.

