import { Routes, Route } from 'react-router-dom';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import Home from './pages/Home';
import './styles/App.scss';

function App() {
  return (
    <ConfigProvider locale={zhCN}>
      <div className="app-container">
        <Routes>
          <Route path="/" element={<Home />} />
        </Routes>
      </div>
    </ConfigProvider>
  );
}

export default App;
