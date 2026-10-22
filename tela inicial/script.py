from flask import Flask, render_template_string

app = Flask(__name__)

# Página principal com o botão HTML integrado
@app.route('/')
def home():
    html_code = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Botão Python</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            .btn { padding: 15px 30px; font-size: 18px; background-color: #007BFF; color: white; border: none; border-radius: 5px; cursor: pointer; }
            .btn:hover { background-color: #0056b3; }
        </style>
    </head>
    <body>
        <h2>Clique no botão para acionar o Python</h2>
        <form action="/clique" method="POST">
            <button type="submit" class="btn">Clique Aqui</button>
        </form>
    </body>
    </html>
    '''
    return render_template_string(html_code)

# Rota que o botão aciona ao ser clicado
@app.route('/clique', methods=['POST'])
def clique_botao():
    print("O botão foi clicado com sucesso no navegador!")
    return "<h1>Sucesso! O Python recebeu o clique do botão.</h1>"

if __name__ == '__main__':
    app.run(debug=True)
