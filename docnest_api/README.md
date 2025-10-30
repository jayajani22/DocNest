# DocNest API

This is the backend API for the DocNest Flutter application. It is built with Django and Django REST Framework.

## Project Structure

The project is divided into four main apps:

- `users`: Handles user registration and authentication (JWT).
- `documents`: Manages document uploads, storage, and retrieval.
- `notes`: Provides CRUD functionality for text notes.
- `passwords`: Securely stores and manages passwords using field-level encryption.

## Getting Started

### Prerequisites

- Python 3.8+
- Pip

### Installation

1.  **Clone the repository (or download the files).**

2.  **Create and activate a virtual environment:**

    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    ```

3.  **Install the dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

4.  **Generate a Fernet key:**

    Run the following command in a Python shell:

    ```python
    from cryptography.fernet import Fernet
    key = Fernet.generate_key().decode()
    print(key)
    ```

    Copy the generated key and replace `'YOUR_FERNET_KEY'` in `docnest_api/settings.py` with it.

5.  **Run database migrations:**

    ```bash
    python manage.py makemigrations
    python manage.py migrate
    ```

6.  **Create a superuser (optional):**

    ```bash
    python manage.py createsuperuser
    ```

7.  **Run the development server:**

    ```bash
    python manage.py runserver
    ```

The API will be running at `http://127.0.0.1:8000/`.

## API Endpoints & Example Responses

### Users

-   **POST** `/api/users/register/`

    **Request Body:**

    ```json
    {
        "username": "testuser",
        "email": "test@example.com",
        "password": "strongpassword123"
    }
    ```

    **Response (201 Created):**

    ```json
    {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com"
    }
    ```

-   **POST** `/api/users/login/`

    **Request Body:**

    ```json
    {
        "email": "test@example.com",
        "password": "strongpassword123"
    }
    ```

    **Response (200 OK):**

    ```json
    {
        "refresh": "<refresh_token>",
        "access": "<access_token>"
    }
    ```

### Documents

-   **GET** `/api/documents/` (Requires Authentication)
-   **POST** `/api/documents/` (Requires Authentication, multipart/form-data)

### Notes

-   **GET** `/api/notes/` (Requires Authentication)
-   **POST** `/api/notes/` (Requires Authentication)

### Passwords

-   **GET** `/api/passwords/` (Requires Authentication)
-   **POST** `/api/passwords/` (Requires Authentication)

## Production Setup (PostgreSQL)

To use PostgreSQL in production, you will need to:

1.  Install `psycopg2-binary` (`pip install psycopg2-binary`).
2.  In `docnest_api/settings.py`, change the `DATABASES` setting:

    ```python
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'your_db_name',
            'USER': 'your_db_user',
            'PASSWORD': 'your_db_password',
            'HOST': 'localhost',
            'PORT': '5432',
        }
    }
    ```

3.  Set `DEBUG = False` in `settings.py`.
4.  Configure `ALLOWED_HOSTS` in `settings.py` with your domain name.
