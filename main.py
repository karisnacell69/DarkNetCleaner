import os
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.textinput import TextInput

class DarkNetUI(BoxLayout):
    def __init__(self, **kwargs):
        super().__init__(orientation='vertical', **kwargs)

        self.cmd = TextInput(
            text="echo DarkNetCleaner Ready",
            size_hint=(1, 0.7)
        )

        run_btn = Button(text="RUN")
        run_btn.bind(on_press=self.run_cmd)

        copy_btn = Button(text="COPY")
        copy_btn.bind(on_press=self.copy_cmd)

        self.add_widget(self.cmd)
        self.add_widget(run_btn)
        self.add_widget(copy_btn)

    def run_cmd(self, instance):
        os.system(self.cmd.text)

    def copy_cmd(self, instance):
        from kivy.core.clipboard import Clipboard
        Clipboard.copy(self.cmd.text)

class DarkApp(App):
    def build(self):
        return DarkNetUI()

DarkApp().run()
