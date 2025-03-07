using System.Drawing.Drawing2D;

namespace SystemVerilogIntegration
{
    public partial class MainWindow : Form
    {
        private string keyboardPathString = ".\\log.mem";
        private string screenPathString = ".\\screen.mem";
        private int width = 64;
        private int height = 64;
        private int screenUpdateDelay = 100;
        public MainWindow()
        {
            InitializeComponent();
            try
            {
                Thread imageUpdate = new(async () =>
                {
                    while (true)
                    {
                        GetImage();
                        await Task.Delay(screenUpdateDelay);
                    }
                });
                imageUpdate.Start();
                File.WriteAllText(keyboardPathString, string.Empty);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            screenPath.Text = screenPathString.ToString();
            keyboardPath.Text = keyboardPathString.ToString();
            screenRefreshDelay.Text = screenUpdateDelay.ToString();
            screenSizeX.Text = width.ToString();
            screenSizeY.Text = height.ToString();
        }

        private void GetImage()
        {
            try
            {
                var image = File.ReadAllText(screenPathString, System.Text.Encoding.UTF8)
                    .Split('\n').Where((s) => !s.StartsWith('/'));

                Bitmap bmp = new(width, height);

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        int index = y * width + x;
                        int pixel = 0xffffff;

                        try
                        {
                            pixel = int.Parse(image.ElementAt(index),
                                System.Globalization.NumberStyles.HexNumber);
                        }
                        catch
                        {
                            pixel = 0xffffff;
                        }

                        int red = (pixel >> 16) & 0xff;
                        int green = (pixel >> 8) & 0xff;
                        int blue = pixel & 0xff;

                        Color color = Color.FromArgb(red, green, blue);
                        bmp.SetPixel(x, y, color);
                    }
                }
                screen.Invoke(new Action(() =>
                {
                    screen.Image?.Dispose();
                    screen.Image = bmp;
                }));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erro ao atualizar a imagem: {ex.Message}");
            }
        }
        private void SendText(object sender, EventArgs e)
        {
            if (keyboard.Text == string.Empty) return;
            File.AppendAllText(keyboardPathString, ((int)keyboard.Text[0]).ToString("X2") + " ");
            keyboard.ResetText();
        }

        private void Screen_Paint(object sender, PaintEventArgs e)
        {
            if (screen.Image == null) return;
            e.Graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
            e.Graphics.PixelOffsetMode = PixelOffsetMode.Half;
            e.Graphics.DrawImage(screen.Image, screen.ClientRectangle);
        }

        private void screenRefreshDelay_TextChanged(object sender, EventArgs e)
        {
            if (!int.TryParse(screenRefreshDelay.Text, out var val)) return;
            screenUpdateDelay = val;
        }

        private void keyboardPath_TextChanged(object sender, EventArgs e)
        {
            keyboardPathString = keyboardPath.Text;
        }

        private void screenPath_TextChanged(object sender, EventArgs e)
        {
            screenPathString = screenPath.Text;
        }

        private void screenSizeX_TextChanged(object sender, EventArgs e)
        {
            if (!int.TryParse(screenSizeX.Text, out var val)) return;
            width = val;
        }

        private void screenSizeY_TextChanged(object sender, EventArgs e)
        {
            if (!int.TryParse(screenSizeY.Text, out var val)) return;
            height = val;
        }

        private void resetInput_Click(object sender, EventArgs e)
        {
            File.WriteAllText(keyboardPathString, string.Empty);
        }
    }
}
