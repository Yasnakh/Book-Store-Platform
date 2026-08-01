BookStore Management Platform
Overview

The BookStore Management Platform is a full-stack web application developed to simulate the functionality of an online bookstore. The application provides user authentication, product management, database integration, and role-based access for administrators and customers.

The project demonstrates full-stack development by combining a Flask backend, relational database design with MySQL, dynamic HTML templates, and responsive frontend styling.

Key Features
User Features
User registration and authentication
Secure login and logout
User profile management
Browse available books
View product information
Administrator Features
Administrator dashboard
Manage products
Edit product information
Manage user accounts
Database administration pages
Database Features
Relational database design
SQL-based data management
CRUD operations
Entity relationship modeling
Optimized database queries
Technologies Used
Backend
Python
Flask
Flask-MySQLdb
Frontend
HTML5
CSS3
Jinja2 Templates
Database
MySQL
SQL
Development Tools
Git
GitHub
MySQL Workbench
Project Architecture
Application-Development/
│
├── main.py
├── templates/
├── static/
├── database/
├── README.md

(Update this tree to match your final repository after removing unnecessary files like venv.)

Database Design

The project includes a relational database designed in MySQL Workbench with entity relationships supporting:

User accounts
Authentication
Product information
Administrative operations
My Contributions

I was responsible for developing the application, including:

Building the Flask backend
Designing and implementing the relational database
Creating SQL queries and database workflows
Developing frontend pages using HTML, CSS, and Jinja templates
Implementing user authentication and session management
Integrating frontend, backend, and database components
Skills Demonstrated
Full-Stack Web Development
Flask
Python
MySQL
SQL Database Design
REST-oriented web application development
Authentication & Session Management
CRUD Operations
HTML & CSS
Git & GitHub
Installation
git clone https://github.com/YOUR_USERNAME/bookstore-management-platform.git

Create a virtual environment:

python -m venv venv

Install dependencies:

pip install -r requirements.txt

Configure your MySQL database and update the connection settings in main.py.

Run the application:

python main.py

The application will be available locally after the Flask server starts.
