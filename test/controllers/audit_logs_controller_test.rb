require "test_helper"

class AuditLogsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as }

  test "lists audit log entries from the API" do
    stub_request(:get, api_url("audit_logs"))
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: { audit_logs: [ { "id" => 1, "action" => "auth.login", "user_id" => 3, "created_at" => "2026-07-04T10:00:00Z" } ], meta: { "count" => 1 } }.to_json
      )

    get audit_logs_path

    assert_response :success
    assert_match "auth.login", response.body
  end

  test "filters by event" do
    stub_request(:get, api_url("audit_logs"))
      .with(query: hash_including({ "event" => "payments.approved" }))
      .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: { audit_logs: [], meta: { "count" => 0 } }.to_json)

    get audit_logs_path, params: { event: "payments.approved" }

    assert_response :success
  end
end
