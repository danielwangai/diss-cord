import {Link} from "react-router-dom";

function Home() {
    return (
        <div>
            Home Page
            <Link to="/create-user">Sign Up</Link>
        </div>
    )
}

export default Home;
