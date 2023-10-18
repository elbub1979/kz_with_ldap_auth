import { render } from "react-dom";

const App = () => {
    return '<div>Hello, Rails 7 Importpin!</div>';
    };

render(`<${App} />`, document.getElementById("root"));