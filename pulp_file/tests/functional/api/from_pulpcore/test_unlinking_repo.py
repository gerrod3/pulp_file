"""Tests that perform action over remotes"""
import pytest


@pytest.mark.parallel
@pytest.mark.skip("Makes S3 runner get stuck, skipping for now")
def test_shared_remote_usage(
    file_repository_api_client,
    file_repository_factory,
    file_content_api_client,
    file_remote_ssl_factory,
    basic_manifest_path,
    monitor_task,
):
    """Verify remotes can be used with different repos."""
    remote = file_remote_ssl_factory(manifest_path=basic_manifest_path, policy="on_demand")

    # Create and sync repos.
    repos = []
    for _ in range(2):
        repo = file_repository_factory()
        monitor_task(
            file_repository_api_client.sync(repo.pulp_href, {"remote": remote.pulp_href}).task
        )
        repos.append(file_repository_api_client.read(repo.pulp_href))

    # Compare contents of repositories.
    contents = set()
    for repo in repos:
        content = file_content_api_client.list(repository_version=repo.latest_version_href)
        assert content.count == 3
        contents.update({c.pulp_href for c in content.results})
    assert len(contents) == 3
