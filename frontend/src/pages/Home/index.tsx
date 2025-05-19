import React from 'react';
import { Result, Button } from 'antd';
import { SmileOutlined } from '@ant-design/icons';
import styles from './Home.module.scss';

const Home: React.FC = () => {
  return (
    <div className={styles.container}>
      <Result
        icon={<SmileOutlined />}
        title="QuizTest 项目启动成功！！！"
        subTitle="欢迎使用 QuizTest AI面试模拟平台"
        extra={[
          <Button type="primary" key="console">
            开始使用
          </Button>,
        ]}
      />
    </div>
  );
};

export default Home; 