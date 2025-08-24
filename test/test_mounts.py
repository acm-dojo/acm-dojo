import pytest

from utils import create_dojo_yml, login, start_challenge, workspace_run


def test_challenge_mounts(admin_session):
    spec = {
        "id": "mounts-dojo",
        "type": "public",
        "modules": [
            {
                "id": "mod",
                "challenges": [
                    {
                        "id": "chal",
                        "mounts": ["data"],
                        "import": {
                            "dojo": "example",
                            "module": "hello",
                            "challenge": "apple",
                        },
                    }
                ],
            }
        ],
        "files": [
            {
                "type": "text",
                "path": "mod/chal/data/hello.txt",
                "content": "hello-from-mount\n",
            }
        ],
    }

    dojo = create_dojo_yml(spec, session=admin_session)

    # Use a random user to start the challenge
    user = login("mount-user", "password", register=True)

    start_challenge(dojo, "mod", "chal", session=user)

    # Verify the mount was copied into /mnt/data
    out = workspace_run("cat /mnt/data/hello.txt", user="mount-user")
    assert out.stdout.strip() == "hello-from-mount"
