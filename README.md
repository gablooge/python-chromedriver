# Python Chromedriver

## Build

```sh
docker build -t samsulhadi/python-chromedriver:0.0.2 .
```

## Push

```sh
docker push samsulhadi/python-chromedriver:0.0.2
```

## Example Django Test Selenium Setup

```python
import os

from django.contrib.contenttypes.models import ContentType
from django.contrib.staticfiles.testing import StaticLiveServerTestCase
from django.test import tag
from django.urls import reverse
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

from e2e.tests.utils import helpers


@tag("e2e")
class BaseSeleniumTest(StaticLiveServerTestCase):
    @classmethod
    def setUpClass(cls):
        ContentType.objects.clear_cache()
        super().setUpClass()
        options = Options()
        # overcome limited resource problems
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--no-sandbox")
        options.add_argument("enable-automation")
        options.add_argument("--disable-extensions")
        options.add_argument("--dns-prefetch-disable")
        options.add_argument("--disable-gpu")
        options.add_argument("--headless")
        driver = webdriver.Chrome(options=options)
        cls.driver = driver
        cls.port = 8888

    @classmethod
    def tearDownClass(cls):
        cls.driver.quit()
        super().tearDownClass()

    def login(self, driver, username, password):
        url = self.live_server_url + reverse("admin:login")
        driver.get(url)
        username_elem = driver.find_element(By.NAME, "username")
        username_elem.clear()
        username_elem.send_keys(username)

        password_elem = driver.find_element(By.NAME, "password")
        password_elem.clear()
        password_elem.send_keys(password)
        driver.find_element(By.XPATH, "//*[@id='login-form']/div/button").click()
        return driver

    def setUp(self):
        pass
```

## Example gitlab ci

```yaml
stages:
  - lint
  - tests

.dev_setup:
  image: "samsulhadi/python-chromedriver:0.0.2"
  before_script:
    - pip install --upgrade pip
    - pip install poetry
    - poetry install --no-interaction --no-root

flake8:
  stage: lint
  extends: .dev_setup
  before_script:
    - !reference [.dev_setup, before_script]
  script:
    - poetry run flake8 . --extend-exclude=dist,build --show-source --statistics
  timeout: 30m
  retry:
    max: 2
    when:
      - runner_system_failure
      - stuck_or_timeout_failure

e2e_tests:
  stage: tests
  extends: .dev_setup
  before_script:
    - !reference [.dev_setup, before_script]
  services:
    - postgres:latest
  variables:
    POSTGRES_USER: postgres
    POSTGRES_DB: postgres
    POSTGRES_PASSWORD: postgres
    PORT: 5432:5432
  script:
    - poetry run python manage.py test e2e --settings=mainapps.settings.dev
  timeout: 30m
```
