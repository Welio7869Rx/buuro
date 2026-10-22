using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

public class TrilhaSonoraForca
{
    // Frequências das notas musicais em Hz
    private const int C4 = 261;
    private const int D4 = 294;
    private const int E4 = 329;
    private const int F4 = 349;
    private const int G4 = 392;
    private const int A4 = 440;
    private const int B4 = 493;
    private const int C5 = 523;

    public static async Task TocarMusicaFundo(CancellationToken token)
    {
        int[,] melodia = {
            { E4, 300 }, { G4, 300 }, { A4, 600 },
            { E4, 300 }, { G4, 300 }, { B4, 150 }, { A4, 450 },
            { E4, 300 }, { G4, 300 }, { A4, 600 },
            { G4, 300 }, { E4, 900 }
        };

        try
        {
            while (!token.IsCancellationRequested)
            {
                for (int i = 0; i < melodia.GetLength(0); i++)
                {
                    if (token.IsCancellationRequested) break;
                    Console.Beep(melodia[i, 0], melodia[i, 1]);
                    await Task.Delay(50, token);
                }
                await Task.Delay(1000, token);
            }
        }
        catch (OperationCanceledException)
        {
            // Tarefa cancelada
        }
        catch (PlatformNotSupportedException)
        {
            Console.WriteLine("Console.Beep não suportado neste sistema.");
        }
    }

    public static void EfeitoInicio()
    {
        Console.Beep(C4, 130);
        Console.Beep(E4, 130);
        Console.Beep(G4, 260);
    }

    public static void EfeitoAcerto()
    {
        Console.Beep(E4, 100);
        Console.Beep(G4, 100);
        Console.Beep(C5, 200);
    }

    public static void EfeitoErro()
    {
        Console.Beep(G4, 150);
        Console.Beep(D4, 300);
        Console.Beep(C4, 150);
    }

    public static void EfeitoVitoria()
    {
        Console.Beep(C4, 150);
        Console.Beep(E4, 150);
        Console.Beep(G4, 150);
        Console.Beep(C5, 400);
    }

    public static void EfeitoDerrota()
    {
        Console.Beep(F4, 300);
        Console.Beep(E4, 300);
        Console.Beep(D4, 300);
        Console.Beep(C4, 600);
    }
}

public class HangmanGame
{
    private static readonly string[] Words = new[] {
        "JAVASCRIPT", "PROGRAMACAO", "NAVEGADOR", "COMPUTADOR", "FRONTEND",
        "INTERNET", "BRASIL", "ALGORITMO", "VARIAVEL", "FUNCAO",
        "BIBLIOTECA", "FRAMEWORK", "BACKEND", "DATABASE", "SERVIDOR",
        "CSS", "HTML", "REACT", "PYTHON", "NODEJS", "ESTRUTURA",
        "OBJETO", "ARRAY", "STRING", "BOOLEAN", "INTERFACE",
        "RESPONSIVO", "SOFTWARE", "HARDWARE", "SISTEMA", "DESENVOLVIMENTO",
        "COMPILADOR", "SEGURANCA", "LOGICA", "GITHUB", "CLOUD",
        "SCRIPT", "APLICACAO", "EXPERIENCIA", "DADOS", "AUTOMACAO",
        "DESIGN", "COMPONENTE", "TEMPLATES", "REUTILIZAVEL"
    };

    private readonly string secretWord;
    private readonly HashSet<char> guessedLetters;
    private readonly HashSet<char> wrongLetters;
    private int remainingLives;

    public HangmanGame()
    {
        var random = new Random();
        secretWord = Words[random.Next(Words.Length)];
        guessedLetters = new HashSet<char>();
        wrongLetters = new HashSet<char>();
        remainingLives = 6;
    }

    public void Run()
    {
        using var cts = new CancellationTokenSource();
        var musicTask = Task.Run(async () => await TrilhaSonoraForca.TocarMusicaFundo(cts.Token), cts.Token);

        try
        {
            TrilhaSonoraForca.EfeitoInicio();
            while (remainingLives > 0)
            {
                ShowBoard();
                Console.Write("Digite uma letra: ");
                var input = Console.ReadLine()?.Trim().ToUpper() ?? string.Empty;

                if (input == "")
                {
                    Console.WriteLine("Digite algo para jogar.");
                    continue;
                }

                if (input.Length != 1 || !char.IsLetter(input[0]))
                {
                    Console.WriteLine("Digite apenas uma letra válida.");
                    continue;
                }

                var letter = input[0];
                if (guessedLetters.Contains(letter) || wrongLetters.Contains(letter))
                {
                    Console.WriteLine($"Você já tentou '{letter}'.");
                    continue;
                }

                if (secretWord.Contains(letter))
                {
                    guessedLetters.Add(letter);
                    TrilhaSonoraForca.EfeitoAcerto();
                    Console.WriteLine($"Boa! A letra {letter} está na palavra.");
                    if (IsWin())
                    {
                        ShowBoard();
                        TrilhaSonoraForca.EfeitoVitoria();
                        Console.WriteLine($"\n🎉 Você venceu! A palavra era: {secretWord}");
                        break;
                    }
                }
                else
                {
                    wrongLetters.Add(letter);
                    remainingLives--;
                    TrilhaSonoraForca.EfeitoErro();
                    Console.WriteLine($"Ops! A letra {letter} não está na palavra. vidas restantes: {remainingLives}");
                }
            }

            if (remainingLives == 0)
            {
                ShowBoard();
                TrilhaSonoraForca.EfeitoDerrota();
                Console.WriteLine($"\n👻 Game over! A palavra era: {secretWord}");
            }
        }
        finally
        {
            cts.Cancel();
            musicTask.Wait(500);
        }
    }

    private void ShowBoard()
    {
        Console.Clear();
        Console.WriteLine("======================================");
        Console.WriteLine("         Jogo da Forca - C#           ");
        Console.WriteLine("======================================");
        Console.WriteLine($"Vidas: {remainingLives}");
        Console.WriteLine($"Letras erradas: {string.Join(' ', wrongLetters)}");
        Console.WriteLine();
        Console.WriteLine(string.Join(' ', secretWord.Select(c => guessedLetters.Contains(c) ? c : '_')));
        Console.WriteLine();
    }

    private bool IsWin()
    {
        return secretWord.All(c => guessedLetters.Contains(c));
    }
}

public static class Program
{
    public static void Main()
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        var game = new HangmanGame();
        game.Run();
        Console.WriteLine("\nObrigado por jogar! Pressione ENTER para sair...");
        Console.ReadLine();
    }
}
