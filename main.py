from asyncio.windows_events import NULL
import datetime
from email.policy import default
import os
from turtle import title
from unittest import result
import pandas as pd
import mysql.connector
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re

app = Flask(__name__)
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
app.secret_key = b'\x99X\x05D\xe5-\xe2\x9d\xd5\x07\xa1\xc9;\x1dd"\x8b\x9a\xa2:\xfe%E2'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '1234@#$'
app.config['MYSQL_DB'] = 'mydb'

mysql = MySQL(app)  


# ---------------- login/register webpage ------------------ 


@app.route('/login/', methods=['GET', 'POST'])
def login():
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        
        username = request.form['username']
        password = request.form['password']
  
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT * FROM accounts WHERE username = %s AND password = %s', (username, password,))
        account = cursor.fetchone()

        if account:
            session['loggedin'] = True
            session['id'] = account['id']
            session['username'] = account['username']
            session['type'] = account['type']
            return redirect(url_for('home'))
        else:
            msg = 'Incorrect username/password!'
    return render_template('index.html', msg=msg)


@app.route('/login/logout')
def logout():
   session.pop('loggedin', None)
   session.pop('id', None)
   session.pop('username', None)
   return redirect(url_for('login'))


@app.route('/login/register', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form and 'email' in request.form:
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT * FROM accounts WHERE username = %s', (username,))
        account = cursor.fetchone()
        if account:
            msg = 'Account already exists!'
        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            msg = 'Invalid email address!'
        elif not re.match(r'[A-Za-z0-9]+', username):
            msg = 'Username must contain only characters and numbers!'
        elif not username or not password or not email:
            msg = 'Please fill out the form!'
        else:
            cursor.execute('INSERT INTO accounts VALUES (NULL, %s, %s, %s, %s)', (username, password, email, "standardUser",))
            mysql.connection.commit()
            msg = 'You have successfully registered!'
    elif request.method == 'POST':
        msg = 'Please fill out the form!'
    return render_template('register.html', msg=msg) 


@app.route('/home/')
def home():
    if 'loggedin' in session:
        if(session['type'] == 'Admin'):
            return render_template('adminHome.html', username=session['username'])
        else:
            return render_template('userHome.html', username=session['username'])
    return redirect(url_for('login'))


@app.route('/login/profile')
def profile():
    if 'loggedin' in session:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT * FROM accounts WHERE id = %s', (session['id'],))
        account = cursor.fetchone()
        return render_template('profile.html', account=account)
    return redirect(url_for('login'))

@app.route('/change-password/', methods=['POST'])
def change_password():
    print(request.form)
    if 'loggedin' in session:
        if request.form.get('new_password') != request.form.get('confirm_password'):
            print("Passwords don't match")
            return redirect(url_for('profile'))
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        
        cursor.execute('UPDATE accounts SET password = %s WHERE id = %s', (request.form.get('new_password'), session['id'],))
        mysql.connection.commit()
        print("Password changed")
        return redirect(url_for('profile'))
    else:
        return redirect(url_for('login'))

@app.route('/UserAccess', methods=['GET', 'POST'])
def UserAccess():
    if request.method == 'POST' and 'query' in request.form:
        if 'loggedin' in session:
            query = request.form['query']
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute(query)
            result = cursor.fetchall()
            return jsonify({'UserQuery': result})
    return render_template('UserAccess.html') 


def htmlResult(result):
    df = pd.DataFrame()
    for x in result:
        df2 = pd.DataFrame(list(x)).T
        df = pd.concat([df, df2])
    df.to_html('templates\sql-data.html')      

 # ------------ Rozhan --------------------   
    
@app.route('/productList')
def productList():
    query = 'SELECT * FROM product'   
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'productList': result})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)
    
@app.route('/usersList')
def usersList():
    query = 'SELECT * FROM user'   
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'usersList': result})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)
    
@app.route('/productCategoryList')
def productCategoryList():
    query = "SELECT DISTINCT product_category FROM product" 
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'productCategoryList': result})  

@app.route('/shoppingList')
def shoppingList():
    query = 'SELECT * FROM shopping_cart_bill'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'shoppingList': result})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)
    
@app.route('/specialOfferList')
def specialOfferList():
    query = 'SELECT product_name, total_price, discount, discount / total_price as off_percent' 
    query += ' FROM shopping_cart_bill'
    query += ' WHERE discount / total_price > 0.15'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'shoppingList': result})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)

        
@app.route('/specialOfferList2')
def specialOfferList2():
    query = 'SELECT product_name, total_price, discount, discount / total_price as off_percent' 
    query += ' FROM shopping_cart_bill'
    query += ' WHERE discount / total_price < 0.3 and product_name like "%a%" limit 5'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'shoppingList2': result})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)
    
 # --------------- Rozhan ---------------------------

# ------------------ Yasna --------------------------
    
def month():
    today = datetime.date.today()
    if int(today.month) == 1:
        result = str(int(today.year)-1) + "-"
        result += "12-"
        result += str(today.day)   
    else:
        result = str(today.year) + "-"
        result += str(int(today.month)-1) + "-"
        result += str(today.day)
    return result

def week():
    today = datetime.date.today()
    if int(today.day) <= 7:
        if int(today.month) == 1:
            result = str(int(today.year)-1) + "-"
            result += "12-"
        else:
            result = str(today.year) + "-"
            result += str(int(today.month)-1) + "-" 
        result += str(int(today.day)-7)     
    else:
        result = str(today.year) + "-"
        result += str(today.month) + "-"
        result += str(int(today.day)-7)   
    return result

@app.route('/top10usersMonth')
def top10usersMonth():
    query = 'SELECT * FROM user as u JOIN shopping_cart_bill as scb on scb.uid = u.uid' 
    query += ' and date < "'+ str(datetime.date.today()) +'" and date > "' + month() + '"'
    query += ' ORDER BY total_price DESC'
    query += ' LIMIT 10'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'top10usersMonth': result})

@app.route('/worst5usersMonth')
def worst5usersMonth():
    query = 'SELECT * FROM user as u JOIN shopping_cart_bill as scb on scb.uid = u.uid' 
    query += ' and date < "'+ str(datetime.date.today()) +'" and date > "' + month() + '"'
    query += ' ORDER BY total_price ASC'
    query += ' LIMIT 10'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'worst5usersMonth': result})

@app.route('/top10usersWeek')
def top10usersWeek():
    query = 'SELECT * FROM user as u JOIN shopping_cart_bill as scb on scb.uid = u.uid' 
    query += ' and date < "'+ str(datetime.date.today()) +'" and date > "' + week() + '"'
    query += ' ORDER BY total_price DESC'
    query += ' LIMIT 10'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'top10usersWeek': result}) 

@app.route('/bestSellingProductsMonth')
def bestSellingProductsMonth():
    query = 'SELECT product_name, date FROM shopping_cart_bill' 
    query += ' WHERE date < "'+ str(datetime.date.today()) +'" and date > "' + month() + '"'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'bestSellingProductsMonth': result}) 

@app.route('/bestSellingProductsWeek')
def bestSellingProductsWeek():
    query = 'SELECT product_name, date FROM shopping_cart_bill' 
    query += ' WHERE date < "'+ str(datetime.date.today()) +'" and date > "' + week() + '"'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'bestSellingProductsWeek': result})

@app.route('/suppliersList', methods=['GET', 'POST'])
def suppliersList():
    if request.method == 'POST' and 'pid' in request.form:
        pid = request.form['pid']
        query = 'SELECT supplier.sid, supplier.name, supplier.score, supplier.city, product_supplier.price'
        query += ' FROM product_supplier, supplier'
        query += ' WHERE product_supplier.sid = supplier.sid AND pid = %s'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query,(pid,))
        result = cursor.fetchall()
        return jsonify({'suppliersList': result})
        # htmlResult(result)
        # return render_template('sql-data.html', result = result)

@app.route('/cheapestItemSuppliersList', methods=['GET', 'POST'])
def cheapestItemSuppliersList():
    if request.method == 'POST' and 'pid' in request.form:
        pid = request.form['pid']
        query = 'SELECT supplier.sid, supplier.name, supplier.score, supplier.city, product_supplier.price'
        query += ' FROM product_supplier, supplier'
        query += ' WHERE product_supplier.sid = supplier.sid AND pid = %s AND'
        query += ' price <= all (SELECT price FROM product_supplier WHERE pid = %s)'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query,(pid,pid))
        result = cursor.fetchall()
        return jsonify({'cheapestItemSuppliersList': result})
        # htmlResult(result)
        # return render_template('sql-data.html', result = result) 

# ----------- Yasna -------------------

# ----------- Sina ---------------------
@app.route('/citySupplierList/', methods=['GET', 'POST'])
def citySupplierList():
    if request.method == 'POST' and 'city' in request.form:
        city = request.form['city']
        query = "SELECT * FROM supplier WHERE city = %s" 
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query,(city,))
        result = cursor.fetchall()
        return jsonify({'citySupplierList': result})
        # htmlResult(result)
        # return render_template('sql-data.html', result = result)

@app.route('/cityUserList/', methods=['GET', 'POST'])
def cityUserList():
    if request.method == 'POST' and 'city' in request.form:
        city = request.form['city']
        query = 'SELECT * FROM user where city = %s' 
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query,(city,))
        result = cursor.fetchall()
        return jsonify({'cityUserList': result})
        # htmlResult(result)
        # return render_template('sql-data.html', result = result)

@app.route('/monthSaleAvg/', methods=['GET', 'POST'])
def monthSaleAvg(): # sample : 2022-12
    if request.method == 'POST' and 'month' in request.form:
        month = request.form['month']
        lowerBound = month + '-01'
        upperBound = month + '-31'
        query = 'SELECT AVG(total_price) FROM shopping_cart_bill WHERE is_sold = TRUE AND (date >= %s AND date <= %s)'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query,(lowerBound,upperBound,))
        result = cursor.fetchall()
        return jsonify({'monthSaleAvg': result})
        # htmlResult(result)
        # return render_template('sql-data.html', result = result)
    
@app.route('/monthSaleCountSpecificProduct/', methods=['GET', 'POST'])
def monthSaleCountSpecificProduct(): # sample : 2022-12
    if request.method == 'POST' and 'month' in request.form and 'pid' in request.form:
        month = request.form['month']
        pid = request.form['pid']
        lowerBound = month + '-01'
        upperBound = month + '-31'
        query = 'SELECT SUM(cart_item.count) FROM shopping_cart_bill, cart_item, product_supplier WHERE shopping_cart_bill.scid = cart_item.scid AND cart_item.psid = product_supplier.psid AND is_sold = TRUE AND pid = %s AND (date >= %s AND date <= %s)'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query,(pid,lowerBound,upperBound,))
        result = cursor.fetchall()
        return jsonify({'monthSaleCountSpecificProduct': result})
        # htmlResult(result)
        # return render_template('sql-data.html', result = result)

# --------- Sina ----------


# --------- Tahmine ----------

@app.route('/commentList/<pid>')
def commentList(pid: int):
    # if session.get('loggedin'):
    query = f"SELECT user.first_name, comment.text, comment.score FROM comment, user WHERE comment.pid = '{pid}' and user.uid = comment.uid"
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'commentList': result})
    # return jsonify ({"error" : 403})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)

@app.route('/best3comments/<pid>')
def best3comments(pid: int):
    # if session.get('loggedin'):
    query = f"SELECT user.first_name, comment.text, comment.score FROM comment, user WHERE comment.pid = '{pid}' and user.uid = comment.uid ORDER BY score DESC LIMIT 3"
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'best3comments': result})
    # return jsonify({"error" : 403})
    # htmlResult(result)
    # return render_template('sql-data.html', result = result)

@app.route('/worst3comments/<pid>')
def worst3comments(pid: int):
    # if session.get('loggedin'):
    query = f"SELECT user.first_name, comment.text, comment.score FROM comment, user WHERE comment.pid = '{pid}' and user.uid = comment.uid ORDER BY score LIMIT 3"
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    return jsonify({'worst3comments': result})
    # return jsonify({"error" : 403})

@app.route('/editProduct', methods=['GET', 'POST'])
def editProduct():
    if session.get('loggedin') and session.get('type') == 'Admin':
        if request.method == 'POST' and request.form.get('pid') != '' and (request.form.get('product_category') != '' or request.form.get('weight') != '') :
            pid = request.form['pid']
            cat = request.form['product_category']
            weight = request.form['weight']
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute('SELECT * FROM product WHERE pid = %s', (pid,))
            product = cursor.fetchone()
            if product:
                if weight != '':
                    cursor.execute(f'UPDATE product SET weight = {weight} WHERE pid = {pid}')
                if cat != '':
                    cursor.execute(f'UPDATE product SET product_category = \'{cat}\' WHERE pid = {pid}')
                mysql.connection.commit()
                return redirect(url_for('home'))
            
        elif request.method == 'POST' and request.form.get('pid') != '':
            pid = request.form['pid']
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute('SELECT * FROM product WHERE pid = %s', (pid,))
            product = cursor.fetchone()
            if product:
                cursor.execute('SET FOREIGN_KEY_CHECKS=OFF')
                cursor.execute(f'DELETE FROM product WHERE pid = {pid}')
                cursor.execute('SET FOREIGN_KEY_CHECKS=ON')
                mysql.connection.commit()
                return redirect(url_for('home'))
        elif request.method == 'POST' and request.form.get('pid') == '' and request.form.get('product_category') != '' and request.form.get('weight') != '':
            cat = request.form['product_category']
            weight = request.form['weight']
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute(f'INSERT INTO product (product_category, weight) VALUES (\'{cat}\', {weight})')
            mysql.connection.commit()
            return redirect(url_for('home'))
        else:
            print("hello")
            return render_template('editProducts.html')
    else:
        return jsonify({"error" : 403})

@app.route('/editUser', methods=['GET', 'POST'])
def editUser():
    if session.get('loggedin') and session.get('type') == 'Admin':
        if request.method == 'POST':
                print(request.form)
                uid = request.form['id']
                username = request.form['username']
                password = request.form['password']
                user_type = request.form['user_type']
                email = request.form['email']
                cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
                cursor.execute('SELECT * FROM accounts WHERE id = %s', (uid,))
                user = cursor.fetchone()
                if user:
                    cursor.execute(f'UPDATE accounts SET username = \'{username}\', password = \'{password}\', type = \'{user_type}\', email = \'{email}\' WHERE id = {uid}')
                    mysql.connection.commit()
                    return redirect(url_for('home'))
                return jsonify({"error" : 'Invalid input'})

        else:
            return render_template('editUser.html')
    else:
        return jsonify({"error" : 403})

# --------- Tahmine ----------


if __name__ == '__main__':
    app.run(debug=True) 