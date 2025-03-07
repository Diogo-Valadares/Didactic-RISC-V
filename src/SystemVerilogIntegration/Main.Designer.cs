namespace SystemVerilogIntegration
{
    partial class MainWindow
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            screen = new PictureBox();
            keyboard = new TextBox();
            screenSizeX = new TextBox();
            screenSizeY = new TextBox();
            screenRefreshDelay = new TextBox();
            keyboardPath = new TextBox();
            screenPath = new TextBox();
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            label4 = new Label();
            resetInput = new Button();
            ((System.ComponentModel.ISupportInitialize)screen).BeginInit();
            SuspendLayout();
            // 
            // screen
            // 
            screen.AccessibleName = "Screen";
            screen.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            screen.BackColor = SystemColors.ControlDark;
            screen.BorderStyle = BorderStyle.FixedSingle;
            screen.Location = new Point(12, 12);
            screen.Name = "screen";
            screen.Size = new Size(256, 256);
            screen.SizeMode = PictureBoxSizeMode.Zoom;
            screen.TabIndex = 0;
            screen.TabStop = false;
            screen.Paint += Screen_Paint;
            // 
            // keyboard
            // 
            keyboard.AcceptsReturn = true;
            keyboard.AcceptsTab = true;
            keyboard.AccessibleName = "Keyboard";
            keyboard.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            keyboard.BorderStyle = BorderStyle.FixedSingle;
            keyboard.Location = new Point(12, 274);
            keyboard.Name = "keyboard";
            keyboard.Size = new Size(256, 23);
            keyboard.TabIndex = 1;
            keyboard.Text = "Type here";
            keyboard.TextAlign = HorizontalAlignment.Center;
            keyboard.TextChanged += SendText;
            // 
            // screenSizeX
            // 
            screenSizeX.AcceptsReturn = true;
            screenSizeX.AcceptsTab = true;
            screenSizeX.AccessibleName = "Keyboard";
            screenSizeX.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            screenSizeX.BorderStyle = BorderStyle.FixedSingle;
            screenSizeX.Location = new Point(141, 388);
            screenSizeX.Name = "screenSizeX";
            screenSizeX.Size = new Size(59, 23);
            screenSizeX.TabIndex = 2;
            screenSizeX.Text = "Type here";
            screenSizeX.TextAlign = HorizontalAlignment.Center;
            screenSizeX.TextChanged += screenSizeX_TextChanged;
            // 
            // screenSizeY
            // 
            screenSizeY.AcceptsReturn = true;
            screenSizeY.AcceptsTab = true;
            screenSizeY.AccessibleName = "Keyboard";
            screenSizeY.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            screenSizeY.BorderStyle = BorderStyle.FixedSingle;
            screenSizeY.Location = new Point(206, 388);
            screenSizeY.Name = "screenSizeY";
            screenSizeY.Size = new Size(62, 23);
            screenSizeY.TabIndex = 2;
            screenSizeY.Text = "Type here";
            screenSizeY.TextAlign = HorizontalAlignment.Center;
            screenSizeY.TextChanged += screenSizeY_TextChanged;
            // 
            // screenRefreshDelay
            // 
            screenRefreshDelay.AcceptsReturn = true;
            screenRefreshDelay.AcceptsTab = true;
            screenRefreshDelay.AccessibleName = "Keyboard";
            screenRefreshDelay.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            screenRefreshDelay.BorderStyle = BorderStyle.FixedSingle;
            screenRefreshDelay.Location = new Point(141, 417);
            screenRefreshDelay.Name = "screenRefreshDelay";
            screenRefreshDelay.Size = new Size(127, 23);
            screenRefreshDelay.TabIndex = 2;
            screenRefreshDelay.Text = "Type here";
            screenRefreshDelay.TextAlign = HorizontalAlignment.Center;
            screenRefreshDelay.TextChanged += screenRefreshDelay_TextChanged;
            // 
            // keyboardPath
            // 
            keyboardPath.AcceptsReturn = true;
            keyboardPath.AcceptsTab = true;
            keyboardPath.AccessibleName = "Keyboard";
            keyboardPath.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            keyboardPath.BorderStyle = BorderStyle.FixedSingle;
            keyboardPath.Location = new Point(141, 446);
            keyboardPath.Name = "keyboardPath";
            keyboardPath.Size = new Size(127, 23);
            keyboardPath.TabIndex = 2;
            keyboardPath.Text = "Type here";
            keyboardPath.TextAlign = HorizontalAlignment.Center;
            keyboardPath.TextChanged += keyboardPath_TextChanged;
            // 
            // screenPath
            // 
            screenPath.AcceptsReturn = true;
            screenPath.AcceptsTab = true;
            screenPath.AccessibleName = "Keyboard";
            screenPath.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            screenPath.BorderStyle = BorderStyle.FixedSingle;
            screenPath.Location = new Point(141, 475);
            screenPath.Name = "screenPath";
            screenPath.Size = new Size(127, 23);
            screenPath.TabIndex = 2;
            screenPath.Text = "Type here";
            screenPath.TextAlign = HorizontalAlignment.Center;
            screenPath.TextChanged += screenPath_TextChanged;
            // 
            // label1
            // 
            label1.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            label1.AutoSize = true;
            label1.Location = new Point(50, 390);
            label1.Name = "label1";
            label1.Size = new Size(85, 15);
            label1.TabIndex = 3;
            label1.Text = "Screen Size X Y";
            label1.TextAlign = ContentAlignment.MiddleRight;
            // 
            // label2
            // 
            label2.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            label2.AutoSize = true;
            label2.Location = new Point(19, 419);
            label2.Name = "label2";
            label2.Size = new Size(116, 15);
            label2.TabIndex = 4;
            label2.Text = "Screen Refresh Delay";
            label2.TextAlign = ContentAlignment.MiddleRight;
            // 
            // label3
            // 
            label3.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            label3.AutoSize = true;
            label3.Location = new Point(50, 448);
            label3.Name = "label3";
            label3.Size = new Size(84, 15);
            label3.TabIndex = 4;
            label3.Text = "Keyboard Path";
            label3.TextAlign = ContentAlignment.MiddleRight;
            // 
            // label4
            // 
            label4.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            label4.AutoSize = true;
            label4.Location = new Point(66, 477);
            label4.Name = "label4";
            label4.Size = new Size(69, 15);
            label4.TabIndex = 4;
            label4.Text = "Screen Path";
            label4.TextAlign = ContentAlignment.MiddleRight;
            // 
            // resetInput
            // 
            resetInput.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            resetInput.Location = new Point(12, 303);
            resetInput.Name = "resetInput";
            resetInput.Size = new Size(256, 23);
            resetInput.TabIndex = 5;
            resetInput.Text = "Reset Input";
            resetInput.UseVisualStyleBackColor = true;
            resetInput.Click += resetInput_Click;
            // 
            // MainWindow
            // 
            AccessibleName = "MainWindow";
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(282, 510);
            Controls.Add(resetInput);
            Controls.Add(label4);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(screenSizeY);
            Controls.Add(screenRefreshDelay);
            Controls.Add(screenPath);
            Controls.Add(keyboardPath);
            Controls.Add(screenSizeX);
            Controls.Add(keyboard);
            Controls.Add(screen);
            Name = "MainWindow";
            Text = "DRISC-V Interface";
            ((System.ComponentModel.ISupportInitialize)screen).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private PictureBox screen;
        private TextBox keyboard;
        private TextBox screenSizeX;
        private TextBox screenSizeY;
        private TextBox screenRefreshDelay;
        private TextBox keyboardPath;
        private TextBox screenPath;
        private Label label1;
        private Label label2;
        private Label label3;
        private Label label4;
        private Button resetInput;
    }
}
