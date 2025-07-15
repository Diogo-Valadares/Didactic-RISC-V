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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainWindow));
            screen = new PictureBox();
            keyboard = new TextBox();
            screenSizeX = new TextBox();
            screenSizeY = new TextBox();
            screenRefreshDelay = new TextBox();
            screenPath = new TextBox();
            label1 = new Label();
            label2 = new Label();
            label4 = new Label();
            resetInput = new Button();
            label3 = new Label();
            keyboardPath = new TextBox();
            terminal = new RichTextBox();
            outputPanels = new TableLayoutPanel();
            tableLayoutPanel2 = new TableLayoutPanel();
            terminalPath = new TextBox();
            terminalLabel = new Label();
            tableLayoutPanel3 = new TableLayoutPanel();
            mainLayoutTable = new TableLayoutPanel();
            ((System.ComponentModel.ISupportInitialize)screen).BeginInit();
            outputPanels.SuspendLayout();
            tableLayoutPanel2.SuspendLayout();
            tableLayoutPanel3.SuspendLayout();
            mainLayoutTable.SuspendLayout();
            SuspendLayout();
            // 
            // screen
            // 
            screen.AccessibleName = "Screen";
            screen.BackColor = SystemColors.ControlDark;
            screen.Dock = DockStyle.Fill;
            screen.Location = new Point(3, 3);
            screen.Name = "screen";
            screen.Size = new Size(303, 303);
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
            keyboard.BorderStyle = BorderStyle.FixedSingle;
            keyboard.Dock = DockStyle.Fill;
            keyboard.Location = new Point(3, 406);
            keyboard.Name = "keyboard";
            keyboard.Size = new Size(618, 23);
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
            screenSizeX.BorderStyle = BorderStyle.FixedSingle;
            screenSizeX.Dock = DockStyle.Fill;
            screenSizeX.Location = new Point(3, 3);
            screenSizeX.Name = "screenSizeX";
            screenSizeX.Size = new Size(86, 23);
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
            screenSizeY.BorderStyle = BorderStyle.FixedSingle;
            screenSizeY.Dock = DockStyle.Fill;
            screenSizeY.Location = new Point(95, 3);
            screenSizeY.Name = "screenSizeY";
            screenSizeY.Size = new Size(87, 23);
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
            screenRefreshDelay.BorderStyle = BorderStyle.FixedSingle;
            screenRefreshDelay.Dock = DockStyle.Fill;
            screenRefreshDelay.Location = new Point(434, 3);
            screenRefreshDelay.Name = "screenRefreshDelay";
            screenRefreshDelay.Size = new Size(181, 23);
            screenRefreshDelay.TabIndex = 2;
            screenRefreshDelay.Text = "Type here";
            screenRefreshDelay.TextAlign = HorizontalAlignment.Center;
            screenRefreshDelay.TextChanged += screenRefreshDelay_TextChanged;
            // 
            // screenPath
            // 
            screenPath.AcceptsReturn = true;
            screenPath.AcceptsTab = true;
            screenPath.AccessibleName = "Keyboard";
            screenPath.BorderStyle = BorderStyle.FixedSingle;
            screenPath.Dock = DockStyle.Fill;
            screenPath.Location = new Point(434, 30);
            screenPath.Name = "screenPath";
            screenPath.Size = new Size(181, 23);
            screenPath.TabIndex = 2;
            screenPath.Text = "Type here";
            screenPath.TextAlign = HorizontalAlignment.Center;
            screenPath.TextChanged += screenPath_TextChanged;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Dock = DockStyle.Fill;
            label1.Location = new Point(3, 0);
            label1.Name = "label1";
            label1.Size = new Size(117, 27);
            label1.TabIndex = 3;
            label1.Text = "Screen Size X Y";
            label1.TextAlign = ContentAlignment.MiddleRight;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Dock = DockStyle.Fill;
            label2.Location = new Point(311, 0);
            label2.Name = "label2";
            label2.Size = new Size(117, 27);
            label2.TabIndex = 4;
            label2.Text = "Screen Refresh Delay";
            label2.TextAlign = ContentAlignment.MiddleRight;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Dock = DockStyle.Fill;
            label4.Location = new Point(311, 27);
            label4.Name = "label4";
            label4.Size = new Size(117, 28);
            label4.TabIndex = 4;
            label4.Text = "Screen Path";
            label4.TextAlign = ContentAlignment.MiddleRight;
            // 
            // resetInput
            // 
            resetInput.Dock = DockStyle.Fill;
            resetInput.Location = new Point(3, 376);
            resetInput.Name = "resetInput";
            resetInput.Size = new Size(618, 24);
            resetInput.TabIndex = 5;
            resetInput.Text = "Reset Input";
            resetInput.UseVisualStyleBackColor = true;
            resetInput.Click += resetInput_Click;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Dock = DockStyle.Fill;
            label3.Location = new Point(3, 27);
            label3.Name = "label3";
            label3.Size = new Size(117, 28);
            label3.TabIndex = 4;
            label3.Text = "Keyboard Path";
            label3.TextAlign = ContentAlignment.MiddleRight;
            // 
            // keyboardPath
            // 
            keyboardPath.AcceptsReturn = true;
            keyboardPath.AcceptsTab = true;
            keyboardPath.AccessibleName = "Keyboard";
            keyboardPath.BorderStyle = BorderStyle.FixedSingle;
            keyboardPath.Dock = DockStyle.Fill;
            keyboardPath.Location = new Point(126, 30);
            keyboardPath.Name = "keyboardPath";
            keyboardPath.Size = new Size(179, 23);
            keyboardPath.TabIndex = 2;
            keyboardPath.Text = "Type here";
            keyboardPath.TextAlign = HorizontalAlignment.Center;
            keyboardPath.TextChanged += keyboardPath_TextChanged;
            // 
            // terminal
            // 
            terminal.BackColor = Color.Black;
            terminal.BorderStyle = BorderStyle.None;
            terminal.Cursor = Cursors.No;
            terminal.Dock = DockStyle.Fill;
            terminal.Font = new Font("Consolas", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            terminal.ForeColor = Color.White;
            terminal.Location = new Point(312, 3);
            terminal.Name = "terminal";
            terminal.ReadOnly = true;
            terminal.RightToLeft = RightToLeft.No;
            terminal.ScrollBars = RichTextBoxScrollBars.Vertical;
            terminal.Size = new Size(303, 303);
            terminal.TabIndex = 10;
            terminal.Text = resources.GetString("terminal.Text");
            terminal.UseWaitCursor = true;
            // 
            // outputPanels
            // 
            outputPanels.AccessibleName = "";
            outputPanels.ColumnCount = 2;
            outputPanels.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            outputPanels.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            outputPanels.Controls.Add(terminal, 1, 0);
            outputPanels.Controls.Add(screen, 0, 0);
            outputPanels.Dock = DockStyle.Fill;
            outputPanels.Location = new Point(3, 3);
            outputPanels.Name = "outputPanels";
            outputPanels.RowCount = 1;
            outputPanels.RowStyles.Add(new RowStyle(SizeType.Percent, 100F));
            outputPanels.Size = new Size(618, 309);
            outputPanels.TabIndex = 11;
            // 
            // tableLayoutPanel2
            // 
            tableLayoutPanel2.ColumnCount = 4;
            tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 20F));
            tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 30F));
            tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 20F));
            tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 30F));
            tableLayoutPanel2.Controls.Add(terminalPath, 1, 2);
            tableLayoutPanel2.Controls.Add(terminalLabel, 0, 2);
            tableLayoutPanel2.Controls.Add(label4, 2, 1);
            tableLayoutPanel2.Controls.Add(screenPath, 3, 1);
            tableLayoutPanel2.Controls.Add(label1, 0, 0);
            tableLayoutPanel2.Controls.Add(screenRefreshDelay, 3, 0);
            tableLayoutPanel2.Controls.Add(label2, 2, 0);
            tableLayoutPanel2.Controls.Add(keyboardPath, 1, 1);
            tableLayoutPanel2.Controls.Add(label3, 0, 1);
            tableLayoutPanel2.Controls.Add(tableLayoutPanel3, 1, 0);
            tableLayoutPanel2.Dock = DockStyle.Fill;
            tableLayoutPanel2.Location = new Point(3, 436);
            tableLayoutPanel2.Name = "tableLayoutPanel2";
            tableLayoutPanel2.RowCount = 3;
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 33.3333321F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 33.3333359F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 33.3333359F));
            tableLayoutPanel2.Size = new Size(618, 84);
            tableLayoutPanel2.TabIndex = 12;
            // 
            // terminalPath
            // 
            terminalPath.AcceptsReturn = true;
            terminalPath.AcceptsTab = true;
            terminalPath.AccessibleName = "Keyboard";
            terminalPath.BorderStyle = BorderStyle.FixedSingle;
            terminalPath.Dock = DockStyle.Fill;
            terminalPath.Location = new Point(126, 58);
            terminalPath.Name = "terminalPath";
            terminalPath.Size = new Size(179, 23);
            terminalPath.TabIndex = 7;
            terminalPath.Text = "Type here";
            terminalPath.TextAlign = HorizontalAlignment.Center;
            terminalPath.TextChanged += terminalPath_TextChanged;
            // 
            // terminalLabel
            // 
            terminalLabel.AutoSize = true;
            terminalLabel.Dock = DockStyle.Fill;
            terminalLabel.Location = new Point(3, 55);
            terminalLabel.Name = "terminalLabel";
            terminalLabel.Size = new Size(117, 29);
            terminalLabel.TabIndex = 6;
            terminalLabel.Text = "Terminal Path";
            terminalLabel.TextAlign = ContentAlignment.MiddleRight;
            // 
            // tableLayoutPanel3
            // 
            tableLayoutPanel3.ColumnCount = 2;
            tableLayoutPanel3.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            tableLayoutPanel3.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            tableLayoutPanel3.Controls.Add(screenSizeX, 0, 0);
            tableLayoutPanel3.Controls.Add(screenSizeY, 1, 0);
            tableLayoutPanel3.Dock = DockStyle.Fill;
            tableLayoutPanel3.Location = new Point(123, 0);
            tableLayoutPanel3.Margin = new Padding(0);
            tableLayoutPanel3.Name = "tableLayoutPanel3";
            tableLayoutPanel3.RowCount = 1;
            tableLayoutPanel3.RowStyles.Add(new RowStyle(SizeType.Percent, 50F));
            tableLayoutPanel3.Size = new Size(185, 27);
            tableLayoutPanel3.TabIndex = 5;
            // 
            // mainLayoutTable
            // 
            mainLayoutTable.ColumnCount = 1;
            mainLayoutTable.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            mainLayoutTable.Controls.Add(tableLayoutPanel2, 0, 4);
            mainLayoutTable.Controls.Add(keyboard, 0, 3);
            mainLayoutTable.Controls.Add(resetInput, 0, 2);
            mainLayoutTable.Controls.Add(outputPanels, 0, 0);
            mainLayoutTable.Dock = DockStyle.Fill;
            mainLayoutTable.Location = new Point(0, 0);
            mainLayoutTable.Name = "mainLayoutTable";
            mainLayoutTable.RowCount = 5;
            mainLayoutTable.RowStyles.Add(new RowStyle(SizeType.Percent, 100F));
            mainLayoutTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 58F));
            mainLayoutTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 30F));
            mainLayoutTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 30F));
            mainLayoutTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 90F));
            mainLayoutTable.Size = new Size(624, 523);
            mainLayoutTable.TabIndex = 13;
            // 
            // MainWindow
            // 
            AccessibleName = "MainWindow";
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(624, 523);
            Controls.Add(mainLayoutTable);
            Name = "MainWindow";
            Text = "DRISC-V Interface";
            Activated += MainWindow_Activated;
            SizeChanged += MainWindow_SizeChanged;
            ((System.ComponentModel.ISupportInitialize)screen).EndInit();
            outputPanels.ResumeLayout(false);
            tableLayoutPanel2.ResumeLayout(false);
            tableLayoutPanel2.PerformLayout();
            tableLayoutPanel3.ResumeLayout(false);
            tableLayoutPanel3.PerformLayout();
            mainLayoutTable.ResumeLayout(false);
            mainLayoutTable.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private PictureBox screen;
        private TextBox keyboard;
        private TextBox screenSizeX;
        private TextBox screenSizeY;
        private TextBox screenRefreshDelay;
        private TextBox screenPath;
        private Label label1;
        private Label label2;
        private Label label4;
        private Button resetInput;
        private Label label3;
        private TextBox keyboardPath;
        private RichTextBox terminal;
        private TableLayoutPanel outputPanels;
        private TableLayoutPanel tableLayoutPanel2;
        private TableLayoutPanel tableLayoutPanel3;
        private TableLayoutPanel mainLayoutTable;
        private TextBox terminalPath;
        private Label terminalLabel;
    }
}
