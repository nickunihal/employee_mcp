mcp_server = MCP::Server.new(
  name: "employee_management",
  title: "Employee Management MCP Server",
  version: "1.0.0",
  instructions: <<~INSTRUCTIONS,
    This server provides employee management capabilities.

    Use search_employees to search for employees
    by name, email or department.
  INSTRUCTIONS
  tools: [
    SearchEmployeesTool,
    GetEmployeeTool,
    EmployeeCountTool
  ]
)

mcp_transport =
  MCP::Server::Transports::StreamableHTTPTransport.new(
    mcp_server
  )

Rails.application.routes.draw do

  mount mcp_transport => "/mcp"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
